# -*- coding: utf-8 -*-
# Grupo 11:
# 83597 Joana Mendonca
# 84715 Filipe Colaco

from search import Problem, Node, Graph, astar_search, breadth_first_tree_search, \
	depth_first_tree_search, greedy_search
import sys
import copy

class RRState:
	state_id = 0

	def __init__(self, board):
		self.board = board
		self.id = RRState.state_id
		RRState.state_id += 1

	def __lt__(self, other):
		""" Este método é utilizado em caso de empate na gestão da lista
		de abertos nas procuras informadas. """
		return self.id < other.id

	def __eq__(self, other):
		""" Verifica se dois estados são iguais, comparando as posições dos robots. """
		return self.board.robot_positions == other.board.robot_positions

	def __hash__(self):
		return hash(self.board)

class Board:
	""" Representacao interna de um tabuleiro de Ricochet Robots. """

	def __init__(self, lines):
		self.robot_positions = {}
		self.walls = {}
		self.dimension = int(lines[0][:-1])

		# add robots
		for i in range(1,5):
			l_s = lines[i].split(' ')
			self.robot_positions[l_s[0]] = (int(l_s[1]), int(l_s[2]))

		# add target
		l_s = lines[5].split(' ')
		self.target = (l_s[0], int(l_s[1]), int(l_s[2]))

		# add inside walls
		for i in range(7, len(lines)):
			l_s = lines[i].split(' ')
			if l_s[0] == '\n' or l_s[1] == '\n': continue
			position = (int(l_s[0]), int(l_s[1]))
			wall = l_s[2][:-1]
			self.checkWalls(position, wall)

			# if there's a wall in one cell, there is on the one across the wall
			if   wall == 'u': self.checkWalls((position[0] - 1, position[1]), 'd')
			elif wall == 'd': self.checkWalls((position[0] + 1, position[1]), 'u')
			elif wall == 'l': self.checkWalls((position[0], position[1] - 1), 'r')
			elif wall == 'r': self.checkWalls((position[0], position[1] + 1), 'l')

		# add outside walls
		for i in range(1, self.dimension + 1):
			self.checkWalls((1, i), 'u')
			self.checkWalls((self.dimension, i), 'd')
			self.checkWalls((i, 1), 'l')
			self.checkWalls((i, self.dimension), 'r')

	def setRobotPosition(self, robot, new_position):
		self.robot_positions[robot] = new_position

	def getCellWall(self, position):
		if position not in self.walls: return ''
		return self.walls[position]

	def robot_position(self, robot: str):
		return self.robot_positions[robot]

	# checks if cell is in "walls"; if so, appends; if not, creates
	def checkWalls(self, position, value):
		if position not in self.walls:
			self.walls[position] = value
		else:
			self.walls[position] += value

def parse_instance(filename: str) -> Board:
	""" Lê o ficheiro cujo caminho é passado como argumento e retorna
	uma instância da classe Board. """
	file = open(filename, 'r')
	lines = file.readlines()
	file.close()
	return Board(lines)

class RicochetRobots(Problem):
	def __init__(self, board: Board):
		""" O construtor especifica o estado inicial. """
		self.board = board
		self.initial = RRState(board)

	def actions(self, state: RRState):
		""" Retorna uma lista de ações que podem ser executadas a
		partir do estado passado como argumento. """
		possible_actions = {'R':'udlr','G':'udlr','B':'udlr','Y':'udlr'}
		robot_positions = state.board.robot_positions

		for robot in robot_positions:
			new_pos = ()
			# check walls in the robot's current position, and remove them from the possible_actions
			for w in state.board.getCellWall(robot_positions[robot]):
				possible_actions[robot] = possible_actions[robot].replace(w, '')

			for m in possible_actions[robot]:
				# generate new positions
				new_pos = calcMove(m, robot_positions[robot])

				# if there's a robot in the new hypothetical position, we can't make that move
				if new_pos in robot_positions.values():
					possible_actions[robot] = possible_actions[robot].replace(m, '')

		result = []
		for r in possible_actions:
			for m in possible_actions[r]:
				result.append((r, m))
		return result

	def result(self, state: RRState, action):
		""" Retorna o estado resultante de executar a 'action' sobre
		'state' passado como argumento. A ação retornada deve ser uma
		das presentes na lista obtida pela execução de
		self.actions(state). action = (robot, move) """
		state_copy = copy.deepcopy(state)
		old_pos = state_copy.board.robot_position(action[0])
		robot_positions = state_copy.board.robot_positions

		while True:
			# check if there's a wall in our way
			if  (old_pos in state_copy.board.walls) and \
				(action[1] in state_copy.board.walls[old_pos]): break

			new_pos = calcMove(action[1], old_pos)
			if new_pos in robot_positions.values(): break
			old_pos = new_pos

		state_copy.board.setRobotPosition(action[0], old_pos)
		return RRState(state_copy.board)

	def goal_test(self, state: RRState):
		""" Retorna True se e só se o estado passado como argumento é
		um estado objetivo. Deve verificar se o alvo e o robô da
		mesma cor ocupam a mesma célula no tabuleiro. """
		target = state.board.target
		position = state.board.robot_position(target[0])
		return position == target[1:]

	def h(self, node: Node):
		""" Função heuristica utilizada para a procura A*. """
		board = node.state.board
		target = board.target[1:]
		position = board.robot_positions[board.target[0]]
		return abs(target[0] - position[0]) + abs(target[1] - position[1])

def calcMove(action, prev):
	if   action == 'u': return (prev[0] - 1, prev[1])
	elif action == 'd': return (prev[0] + 1, prev[1])
	elif action == 'l': return (prev[0], prev[1] - 1)
	elif action == 'r': return (prev[0], prev[1] + 1)

if __name__ == "__main__":
	rr = RicochetRobots(parse_instance(sys.argv[1]))

	result_node = astar_search(rr).solution()
	print(len(result_node), end = '')
	for i in result_node:
		print('\n%s %s' % (i[0], i[1]), end = '')
