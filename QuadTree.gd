extends Node2D
class_name QuadTree

# Constants
@export var MAX_OBJECTS = 16
@export var MAX_LEVELS = 10
const CHUNK_SIZE = 32  # Adjust based on your chunk dimensions

# Properties
@export var bounds = Rect2()
@export var objects = []
@export var subnodes = []
@export var level = 0
@export var chunk_map = {}  # Dictionary to map chunk positions to Chunk nodes

# Constructor
func _init(_bounds : Rect2):
	self.bounds = _bounds

func insert(object : Object):
	if self.level < MAX_LEVELS and len(self.objects) >= MAX_OBJECTS:
		self.subdivide()
		for subnode in self.subnodes:
			if subnode.bounds.has_point(object.position):
				subnode.insert(object)
				return
	self.objects.append(object)

func has_chunk_id(id : Vector2):
	for i in objects:
		if i.chunk_id == id:
			return i
		else:
			return false
	
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
	self.objects = []
	self.level += 1

# Specialized functions for chunk management
func load_chunk(chunk_position : Vector2):
	if chunk_position in chunk_map:
		return  # Chunk already loaded
	var chunk = Chunk.new(chunk_position)  # Replace with your Chunk class
	chunk_map[chunk_position] = chunk
	insert(chunk)  # Add chunk to quadtree for queries

func unload_chunk(chunk_position : Vector2):
	if chunk_position in chunk_map:
		var chunk = chunk_map.pop(chunk_position)
		chunk.unload()  # Unload chunk data
		remove_object(chunk)  # Remove from quadtree

func remove_object(object : Object):
	self.objects.erase(object)
	if not self.objects and self.subnodes:
		self.subnodes = []  # Consolidate if empty

func _to_string():
	if subnodes.size() > 0:
		for subnode in subnodes:
			subnode.to_string()
	for i in objects:
		print(i)

func query_chunks(range : Rect2):
	var chunk_positions = []
	for chunk_position in chunk_map.keys():
		var chunk_bounds = get_chunk_bounds(chunk_position)
		if chunk_bounds.intersects(range):
			chunk_positions.append(chunk_position)
	return chunk_positions

# Helper function to get chunk bounds
func get_chunk_bounds(chunk_position : Vector2):
	var chunk_x = chunk_position.x * CHUNK_SIZE
	var chunk_y = chunk_position.y * CHUNK_SIZE
	return Rect2(chunk_x, chunk_y, CHUNK_SIZE, CHUNK_SIZE)


#extends Resource
#class_name QuadTree
#
## Constants
#const MAX_OBJECTS = 16
#const MAX_LEVELS = 10
## Propterties
#var bounds = Rect2() # bounding area of quadtree
#var objects = [] # Objects contained in this quadtree
#var subnodes = [] # Number of subdivisions if any
#var level = 0 # Current Level
#
## Constructor
#func _init(_bounds : Rect2):
	#self.bounds = _bounds
#
#func insert(object : Object):
	#if self.level < MAX_LEVELS and len(self.objects) >= MAX_OBJECTS:
		#self.subdivide()
		#for subnode in self.subnodes:
			#if subnode.bounds.has_point(object.position):
				#subnode.insert(object)
				#return
	#self.objects.append(object)
#
#func query_range(range : Rect2):
	#var results = []
	#if not self.bounds.intersects(range):
		#return results
	#for object in self.objects:
		#if range.has_point(object.position):
			#results.append(object)
	#if self.subnodes:
		#for subnode in self.subnodes:
			#results += subnode.query_range(range)
	#return results
#
#func subdivide():
	#var sub_width = self.bounds.size.x / 2
	#var sub_height = self.bounds.size.y / 2
	#self.subnodes = [
		#QuadTree.new(
			#Rect2(
				#self.bounds.position,
				#Vector2(sub_width, sub_height)
			#)
		#),
		#QuadTree.new(
			#Rect2(
				#self.bounds.position + Vector2(sub_width, 0),
				#Vector2(sub_width, sub_height)
			#)
		#),
		#QuadTree.new(
			#Rect2(
				#self.bounds.position + Vector2(0, sub_height),
				#Vector2(sub_width, sub_height)
			#)
		#),
		#QuadTree.new(
				#Rect2(
					#self.bounds.position + Vector2(sub_width, sub_height),
					#Vector2(sub_width, sub_height)
				#)
			#)
		#]
	#for object in self.objects:
		#for subnode in self.subnodes:
			#if subnode.bounds.has_point(object.position):
				#subnode.insert(object)
	#self.objects = []
	#self.level += 1
	#
