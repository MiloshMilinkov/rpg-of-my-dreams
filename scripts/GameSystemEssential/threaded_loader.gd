# Makes this script a Node so it can receive frame-by-frame _process calls.
extends Node

# Maps each active resource path to its completion and progress callback arrays.
var _active_load_request: Dictionary = {}

# Runs every processing frame; _delta is unused because loading is status-based.
func _process(_delta: float) -> void:
	# Checks whether there are any registered loads to monitor.
	# Skips the remaining work when there are no active requests.
	if _active_load_request.is_empty():
		return

	# Stores paths whose entries should be removed after this polling loop.
	var completed_resource_paths: Array[String] = []

	# Visits a snapshot of the resource paths currently registered for loading.
	for resource_path in _active_load_request.keys():
		# Creates an array that Godot can fill with this request's progress ratio.
		var progress_status_array: Array = []

		# Gets the request's current state and asks Godot to populate progress.
		var current_load_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(resource_path, progress_status_array)

		# Chooses the appropriate action based on the resource's loading state.
		match current_load_status:
			# Handles a resource that is still loading.
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				# Reads progress if present; otherwise uses zero.
				# Despite the name, this is a ratio from 0.0 to 1.0, not 0 to 100.
				var progress_percentage: float = progress_status_array[0] as float if progress_status_array else 0.0

				# Visits each progress callback registered for this resource.
				for callback_function: Callable in _active_load_request[resource_path].progress_callbacks:
					# Checks that the callback can still be called.
					if callback_function.is_valid():
						# Immediately sends the current progress ratio to that callback.
						callback_function.call(progress_percentage)

			# Handles a resource whose threaded loading has completed successfully.
			ResourceLoader.THREAD_LOAD_LOADED:
				# Collects the loaded Resource now that its status says it is ready.
				var final_resource: Resource = ResourceLoader.load_threaded_get(resource_path)

				# Visits each completion callback waiting for this resource.
				for callback_function: Callable in _active_load_request[resource_path].completion_callbacks:
					# Skips callbacks that are no longer valid, such as freed targets.
					if callback_function.is_valid():
						# Immediately passes the loaded Resource to the callback.
						# The request is still registered while this callback runs.
						callback_function.call(final_resource)

				# Marks this request for removal after all paths have been checked.
				completed_resource_paths.append(resource_path)

			# Handles either a failed load or an invalid threaded request.
			ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				# Prints the affected resource path to the error output.
				printerr("ThreadedLoader: Failed to load: ", resource_path)

				# Visits each completion callback waiting for the failed request.
				for callback_function: Callable in _active_load_request[resource_path].completion_callbacks:
					# Checks whether this callback is still valid before invoking it.
					if callback_function.is_valid():
						# Reports failure by passing null instead of a Resource.
						# A retry here still sees the old request in the dictionary.
						callback_function.call(null)

				# Marks this failed or invalid request for removal.
				completed_resource_paths.append(resource_path)

	# Visits every request that reached a terminal state during this frame.
	for resource_path in completed_resource_paths:
		# Removes this script's tracking entry and its stored callback arrays.
		# This does not itself collect or release an outstanding engine load result.
		_active_load_request.erase(resource_path)

func load_async(resource_path: String, on_load_finished: Callable, on_progress_update: Callable = Callable()) -> void:
	if ResourceLoader.has_cached(resource_path):
		on_load_finished.call(ResourceLoader.load(resource_path))
		return
		
	if not _active_load_request.has(resource_path):
		var error_code: Error = ResourceLoader.load_threaded_request(resource_path, "", true)

		if error_code != OK:
			printerr("ThreadedLoader: Thread request error for:  ", resource_path)
			on_load_finished.call(null)
			return

		_active_load_request[resource_path] = {
			"completion_callbacks": [],
			"progress_callbacks": []

		}
	_active_load_request[resource_path].completion_callbacks.append(on_load_finished)

	if on_progress_update.is_valid():
		_active_load_request[resource_path].progress_callbacks.append(on_progress_update)
