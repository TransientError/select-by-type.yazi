local categories = {
	{ key = "i", desc = "Images", prefix = "image/" },
	{ key = "v", desc = "Video", prefix = "video/" },
	{ key = "a", desc = "Audio", prefix = "audio/" },
	{ key = "t", desc = "Text", prefix = "text/" },
	{ key = "p", desc = "PDF", prefix = "application/pdf" },
}

-- Extension-based fallback when MIME is not yet loaded
local ext_map = {
	["image/"] = {
		png = true, jpg = true, jpeg = true, gif = true, webp = true, bmp = true,
		svg = true, tiff = true, tif = true, ico = true, heic = true, heif = true,
		avif = true, jxl = true, raw = true, cr2 = true, nef = true, arw = true,
	},
	["video/"] = {
		mp4 = true, mkv = true, avi = true, mov = true, wmv = true, flv = true,
		webm = true, m4v = true, mpg = true, mpeg = true, ts = true, ogv = true,
	},
	["audio/"] = {
		mp3 = true, flac = true, ogg = true, wav = true, aac = true, m4a = true,
		wma = true, opus = true, ape = true, alac = true, aiff = true, mid = true,
	},
	["text/"] = {
		txt = true, md = true, log = true, csv = true, json = true, xml = true,
		yaml = true, yml = true, toml = true, ini = true, cfg = true, conf = true,
		sh = true, bash = true, zsh = true, fish = true, lua = true, py = true,
		js = true, ts = true, rs = true, go = true, c = true, h = true, cpp = true,
		java = true, rb = true, html = true, css = true, vim = true,
	},
	["application/pdf"] = {
		pdf = true,
	},
}

local function matches_by_ext(prefix, filename)
	local exts = ext_map[prefix]
	if not exts then return false end
	local ext = filename:match("%.([^%.]+)$")
	if not ext then return false end
	return exts[ext:lower()] or false
end

local get_matching = ya.sync(function(_, prefix)
	local tab = cx.active
	local files = tab.current.files

	local paths = {}
	local all_selected = true

	for i = 1, #files do
		local file = files[i]
		if not file.cha.is_dir then
			local mime = file:mime()
			local matched = false

			if mime then
				if mime:find(prefix, 1, true) == 1 then
					matched = true
				end
			else
				-- Fallback to extension when MIME not yet loaded
				if matches_by_ext(prefix, file.name) then
					matched = true
				end
			end

			if matched then
				paths[#paths + 1] = tostring(file.url)
				if not file:is_selected() then
					all_selected = false
				end
			end
		end
	end

	return paths, all_selected
end)

local function entry(_, job)
	local prefix

	-- Direct invocation with argument
	if job.args and job.args[1] then
		local arg = job.args[1]
		for _, cat in ipairs(categories) do
			if cat.prefix:find(arg, 1, true) == 1 or cat.desc:lower() == arg then
				prefix = cat.prefix
				break
			end
		end
		prefix = prefix or (arg .. "/")
	else
		-- Interactive picker
		local cands = {}
		for _, cat in ipairs(categories) do
			cands[#cands + 1] = { on = cat.key, desc = cat.desc }
		end

		local idx = ya.which({ cands = cands })
		if not idx then
			return
		end
		prefix = categories[idx].prefix
	end

	local paths, all_selected = get_matching(prefix)

	if #paths == 0 then
		ya.notify({ title = "select-by-type", content = "No matching files found", level = "warn", timeout = 3 })
		return
	end

	-- Reconstruct Url objects from strings (ownership transfer requires this)
	local urls = {}
	for i, path in ipairs(paths) do
		urls[i] = Url(path)
	end
	urls.state = all_selected and "off" or "on"
	ya.emit("toggle_all", urls)

	local action = all_selected and "Deselected" or "Selected"
	ya.notify({ title = "select-by-type", content = action .. " " .. #paths .. " files", level = "info", timeout = 2 })
end

return { entry = entry }
