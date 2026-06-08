local categories = {
	{ key = "i", desc = "Images", prefix = "image/" },
	{ key = "v", desc = "Video", prefix = "video/" },
	{ key = "a", desc = "Audio", prefix = "audio/" },
	{ key = "t", desc = "Text", prefix = "text/" },
	{ key = "p", desc = "PDF", prefix = "application/pdf" },
}

local select_by_prefix = ya.sync(function(_, prefix)
	local tab = cx.active
	local files = tab.current.files

	local matching = {}
	local all_selected = true

	for i = 0, #files - 1 do
		local file = files[i]
		local mime = file:mime()
		if mime and mime:find(prefix, 1, true) == 1 then
			matching[#matching + 1] = Url(file.url)
			if not file:is_selected() then
				all_selected = false
			end
		end
	end

	return matching, all_selected
end)

local function do_toggle(matching, all_selected)
	if #matching == 0 then
		ya.notify({ title = "select-by-type", content = "No matching files found (MIME not loaded?)", level = "warn", timeout = 3 })
		return
	end

	local state = all_selected and "off" or "on"
	for _, url in ipairs(matching) do
		ya.manager_emit("toggle", { url, state = state })
	end

	local action = all_selected and "Deselected" or "Selected"
	ya.notify({ title = "select-by-type", content = action .. " " .. #matching .. " files", level = "info", timeout = 2 })
end

local function entry(_, job)
	-- Direct invocation with argument
	if job.args and job.args[1] then
		local arg = job.args[1]
		local prefix
		for _, cat in ipairs(categories) do
			if cat.prefix:find(arg, 1, true) == 1 or cat.desc:lower() == arg then
				prefix = cat.prefix
				break
			end
		end
		prefix = prefix or (arg .. "/")
		local matching, all_selected = select_by_prefix(prefix)
		do_toggle(matching, all_selected)
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

	local matching, all_selected = select_by_prefix(categories[idx].prefix)
	do_toggle(matching, all_selected)
end

return { entry = entry }
