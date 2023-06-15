local Lasso, Connections = {}, {}
local CoreGui = game.CoreGui
local Players, UserInputService, RunService = game:GetService('Players'), game:GetService('UserInputService'), game:GetService('RunService')

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()

Lasso.__index = Lasso

function Lasso.new()

    return setmetatable({

        UI              = Instance.new('ScreenGui', CoreGui),
        InitialPosition = nil

    }, Lasso)

end

function Lasso:HighlightObject(Object, Colour)

    local BoxHandleAdornment = Instance.new('BoxHandleAdornment', Object)
    BoxHandleAdornment.Name = 'AncestorSelectedObject'
    BoxHandleAdornment.Adornee = Object
    BoxHandleAdornment.AlwaysOnTop = true
    BoxHandleAdornment.ZIndex = 0;
    BoxHandleAdornment.Size = Object.Size
    BoxHandleAdornment.Transparency = 0;
    BoxHandleAdornment.Color = BrickColor.new(Colour)

end

function Lasso:InitiateDrag()

    Connections.StopClick = {Function = Mouse.Button1Up:Connect(function()

        Connections.StopClick.Function:Disconnect()
        Connections.MoveMoved.Function:Disconnect()
        Connections.Checker.Function:Disconnect()

        self.InitialPosition = nil
        self.UI:Destroy()

    end)}

    Connections.Clicked = {Function = Mouse.Button1Down:Connect(function()

        self.InitialPosition = {X = Mouse.X, Y = Mouse.Y}

        Connections.Clicked.Function:Disconnect()

        Connections.Checker = {Function = RunService.Stepped:Connect(function()
    
            self.Objects, ObjectsNotInFrame = self:GetContainerInstances(PlayerModels, Player)
    
            for Object in next, self.Objects do
    
                self:HighlightObject(Object.Main, 1)
    
            end

            for Object in next, ObjectsNotInFrame do
    
                pcall(function()

                    Object.Main.AncestorSelectedObject:Destroy()

                end)
    
            end

            self.Objects = {}
            
        end)}

        Connections.MoveMoved = {Function = Mouse.Move:Connect(function()

            local NewPosition = {X = Mouse.X, Y = Mouse.Y}

            local MainFrame = self.UI.MainFrame
            MainFrame.Size = UDim2.new(0, (NewPosition.X - self.InitialPosition.X), 0, (NewPosition.Y - self.InitialPosition.Y))
            MainFrame.Position = UDim2.new(0, self.InitialPosition.X, 0, self.InitialPosition.Y)
        
        end)}
    
    end)}

end

--> Skidded from silent 

function Lasso:IsObjectInLassoFrame(ScreenPosition, Frame)

    return ScreenPosition.X >= Frame.AbsolutePosition.X and ScreenPosition.X <= Frame.AbsolutePosition.X + Frame.AbsoluteSize.X and ScreenPosition.Y >= Frame.AbsolutePosition.Y and ScreenPosition.Y <= Frame.AbsolutePosition.Y + Frame.AbsoluteSize.Y

end

function Lasso:GetContainerInstances(Folder, Player)

    local Children, ObjectsInFrame, ObjectsNotInFrame = Folder:GetChildren(), {}, {}

    for i = 1, #Children do

        local Object = Children[i]

        local Owner = Object:FindFirstChild('Owner')
        local Main = Object:FindFirstChild('Main')
        
        if Owner and Owner.Value == Player and Main then 

            local ObjectScreenPosition = Camera:WorldToScreenPoint(Main.CFrame.p)

            local IsInLasso = self:IsObjectInLassoFrame(ObjectScreenPosition, self.UI.MainFrame)

            if IsInLasso then 

                ObjectsInFrame[Object] = true

            elseif not IsInLasso then

                ObjectsNotInFrame[Object] = true

            end

        end

    end 

    return ObjectsInFrame, ObjectsNotInFrame

end

function Lasso:Create()

    local UI = self.UI
    local MainFrame = Instance.new('Frame', UI)
    MainFrame.Name = 'MainFrame'
    UI.Name = 'Lasso'

    MainFrame.Size = UDim2.new()
    MainFrame.BorderSizePixel = 0
    MainFrame.BackgroundTransparency = .8
    MainFrame.BorderColor3 = Color3.fromRGB(25, 25, 255)
    MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 225)

    self:InitiateDrag()

end

return Lasso
