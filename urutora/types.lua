local types = {}

types.nodeTypes = {
  LABEL = 1,
  BUTTON = 2,
  SLIDER = 3,
  TOGGLE = 4,
  TEXT = 5,
  MULTI = 6,
  PANEL = 7,
  JOY = 8,
  IMAGE = 9,
  ANIMATION = 10,
  PROGRESS_BAR = 11
}

types.alignments = {
  LEFT = 'left',
  CENTER = 'center',
  RIGHT = 'right'
}

types.mouseButtons = {
  LEFT = 1,
  RIGHT = 2
}

function types.isLabel(node)       return node.type == types.nodeTypes.LABEL end
function types.isPanel(node)       return node.type == types.nodeTypes.PANEL end
function types.isMulti(node)       return node.type == types.nodeTypes.MULTI end
function types.isImage(node)       return node.type == types.nodeTypes.IMAGE end
function types.isAnimation(node)   return node.type == types.nodeTypes.ANIMATION end
function types.isToggle(node)      return node.type == types.nodeTypes.TOGGLE end
function types.isProgressBar(node) return node.type == types.nodeTypes.PROGRESS_BAR end
function types.isSlider(node)      return node.type == types.nodeTypes.SLIDER end
function types.isButton(node)      return node.type == types.nodeTypes.BUTTON end
function types.isTextField(node)   return node.type == types.nodeTypes.TEXT end
function types.isJoy(node)         return node.type == types.nodeTypes.JOY end

return types
