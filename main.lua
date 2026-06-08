--- select-by-type.yazi
--- Toggles selection on files by MIME type category using an interactive picker.
--- Usage: plugin select-by-type (opens picker)
---        plugin select-by-type -- image (direct, no picker)

local categories = {
	{ key = "i", desc = "Images", prefix = "image/" },
	{ key = "v", desc = "Video", prefix = "video/" },
	{ key = "a", desc = "Audio", prefix = "audio/" },
	{ key = "t", desc = "Text", prefix = "text/" },
	{ key = "p", desc = "PDF", prefix = "application/pdf" },
}

local function select_by_prefix(prefix)
	local tab = cx.active
	local files = tab.current.files

	local matching_indices = {}
	local all_selected = true

	for i = 0, #files - 1 do
		local file = files[i]
		local mime = file:mime()
		if mime and mime:find(prefix, 1, true) == 1 then
			matching_indices[#matching_indices + 1] = i
			if not file:is_selected() then
				all_selected = false
			end
		end
	end

	if #matching_indices == 0 then
		ya.notify({ title = "select-by-type", content = "No matching files found", level = "warn", timeout = 3 })
		return
	end

	local state = all_selected and "off" or "on"
	for _, idx in ipairs(matching_indices) do
		ya.manager_emit("toggle", { state = state, idx = idx })
	end

	local action = all_selected and "Deselected" or "Selected"
	ya.notify({ title = "select-by-type", content = action .. " " .. #matching_indices .. " files", level = "info", timeout = 2 })
end

local function entry(_, job)
	-- Direct invocation with argument
	if job.args and job.args[1] then
		local arg = job.args[1]
		for _, cat in ipairs(categories) do
			if cat.prefix:find(arg, 1, true) == 1 or cat.desc:lower() == arg then
				select_by_prefix(cat.prefix)
				return
			end
		end
		-- Treat as raw prefix
		select_by_prefix(arg .. "/")
		return
	end

	-- Interactive picker
	local cands = {}
	for _, cat in ipairs(categories) do
		cands[#cands + 1] = { on = cat.key, desc = cat.desc }
	end

	local idx = ya.which({ cands = cands })
	if not idx then
		return
	end

	select_by_prefix(categories[idx].prefix)
end

return { entry = entry }
