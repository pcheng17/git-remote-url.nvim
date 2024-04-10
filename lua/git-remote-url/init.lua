local M = {}

local defaults = {
    default_branch = "main"
}

local function build_url(branch)
	local git_url = vim.fn.system("git config --get remote.origin.url")
	if git_url == "" then
		error("Not a git repository")
		return
	end
	if string.find(git_url, "https://") then
		git_url = string.sub(git_url, 1, -6)
	elseif string.find(git_url, "git@") then
		git_url = "https://github.com/" .. string.sub(git_url, 16, -1)
	end

	local path = vim.fn.expand("%")
	local lineNum = vim.api.nvim__buf_stats(0).current_lnum
	local combined = git_url .. "/blob/" .. branch .. "/" .. path .. "#L" .. lineNum

	return combined
end

M.setup = function(opts)
    opts = opts or {}
    opts = vim.tbl_extend("force", defaults, opts)

	vim.api.nvim_create_user_command('CopyGithubLink', function()
		local combined = build_url(opts.default_branch)
		vim.fn.setreg("+", combined)
	end, {})

	vim.api.nvim_create_user_command('CopyGithubLinkWithBranchName', function()
		local branch = string.sub(vim.fn.system("git branch --show-current"), 1, -2)
		local combined = build_url(branch)
		vim.fn.setreg("+", combined)
	end, {})
end

return M
