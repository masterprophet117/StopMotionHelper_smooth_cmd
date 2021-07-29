local PANEL = {}

function PANEL:Init()

	self:SetWorldClicker(true)
	self.m_bStretchToFit = true

	self:SetPos(0, 0)
	self:SetSize(ScrW(), ScrH())

	self:MakePopup()
	self:SetVisible(false)

end

function PANEL:SetVisible(visible)
	if not visible then
		RememberCursorPosition()
	end
	self.BaseClass.SetVisible(self, visible)
	if visible then
		RestoreCursorPosition()
	end
end

function PANEL:OnMousePressed(mousecode)
	if mousecode ~= MOUSE_RIGHT then
		return
	end

	local trace = util.TraceLine(util.GetPlayerTrace(LocalPlayer()))
	if IsValid(trace.Entity) then
		self:OnEntitySelected(trace.Entity)
	end
end

function PANEL:OnEntitySelected(entity) end

vgui.Register("SMHWorldClicker", PANEL, "EditablePanel")
