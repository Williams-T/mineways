extends Resource
class_name QuadTree

# Constants
const MAX_OBJECTS = 16
const MAX_LEVELS = 10
# Propterties
var bounds = Rect2() # bounding area of quadtree
var objects = [] # Objects contained in this quadtree
var subnodes = [] # Number of subdivisions if any
var level = 0 # Current Level

# Constructor
func _init(_bounds : Rect2):
	self.bounds = _bounds

func insert(object : Block):
	if self.level < MAX_LEVELS and len(self.objects) >= MAX_OBJECTS:
		self.subdivide()
		for subnode in self.subnodes:
			if subnode.bounds.has_point(object.position):
				subnode.insert(object)
				return
	self.objects.append(object)

func query_range(range : Rect2):
	var results = []
	if not self.bounds.intersects(range):
		return results
	for object in self.objects:
		if range.has_point(object.position):
			results.append(object)
	if self.subnodes:
		for subnode in self.subnodes:
			results += subnode.query_range(range)
	return results

func subdivide():
	var sub_width = self.bounds.size.x / 2
	var sub_height = self.bounds.size.y / 2
	self.subnodes = [
		QuadTree.new(
			Rect2(
				self.bounds.position,
				Vector2(sub_width, sub_height)
			)
		),
		QuadTree.new(
			Rect2(
				self.bounds.position + Vector2(sub_width, 0),
				Vector2(sub_width, sub_height)
			)
		),
		QuadTree.new(
			Rect2(
				self.bounds.position + Vector2(0, sub_height),
				Vector2(sub_width, sub_height)
			)
		),
		QuadTree.new(
				Rect2(
					self.bounds.position + Vector2(sub_width, sub_height),
					Vector2(sub_width, sub_height)
				)
			)
		]
	for object in self.objects:
		for subnode in self.subnodes:
			if subnode.bounds.has_point(object.position):
				subnode.insert(object)
	self.objects = []
	self.level += 1
	
