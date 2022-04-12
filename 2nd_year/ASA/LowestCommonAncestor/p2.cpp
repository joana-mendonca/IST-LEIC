/***********************************************************************************************************
 *                          ASA Projeto 2 - Grupo tp037
 *                             Joana Mendonca, 83597
 ***********************************************************************************************************/
#include <stdio.h>
#include <assert.h>
#include <iostream>
#include <list>
#include <algorithm>
#include <unordered_set>


using namespace std;


class Graph{
	int V; /* No. of vertices*/
	list<int> *adj; /*Pointer to a list containing adjacency lists (children)*/
	list<int> *transpose; /*List containing transposed graph*/
	list<int> ancestors_v1;
	list<int> ancestors_v2;
	int *in_degree; /*No. of parents each node can have (it can be 0,1 or 2)*/
	int *out_degree; /*No. of children each node has*/
	bool isCyclicAuxiliar(int v, bool visited[], bool *rs); 
public:
	Graph(int V); // Constructor
	int addEdge(int x, int y, int cnt); // to add an edge to graph
	bool isCyclic(); // returns true if there is a cycle in this graph
	void transposeGraph(int v);
	void BFS(int s, int flag);
	list<int> mergeLists();
	void LCA(list<int> common_ancestors);
};

Graph::Graph(int V){
	this->V = V;

	adj = new list<int>[V+1];
	transpose = new list<int>[V+1];
	
	/*
	ancestors_v1 = new int[V+1];
	ancestors_v2 = new int[V+1];
	for (int i = 0; i <= V; ++i){
		ancestors_v1[i] = 0;
		ancestors_v2[i]= 0;
	}*/
	
	in_degree = new int[V+1];
	out_degree = new int[V+1];
	for (int i = 0; i <= V; ++i){
		this->in_degree[i] = 0;
		this->out_degree[i] = 0;
	}
}

int Graph::addEdge(int x, int y, int cnt){
	adj[x].push_back(y); 
	transpose[y].push_back(x);
	in_degree[y]++;
	if(in_degree[y] > 2)
		return -1;
	out_degree[x] = cnt;

	return 0;
}


/******************************************************************************************************************************
 * 
 *  BFS
 * 
 ******************************************************************************************************************************/
void Graph::BFS(int s, int flag){
    // Mark all the vertices as not visited
    bool *visited = new bool[V];
    for(int i = 0; i <= V; i++)
        visited[i] = false;
 
    // Create a queue for BFS
    list<int> queue;
 
    // Mark the current node as visited and enqueue it
    visited[s] = true;
    queue.push_back(s);


    // 'i' will be used to get all adjacent vertices of a vertex
    list<int>::iterator i;
 
    while(!queue.empty()) {
        // Dequeue a vertex from queue and print it
        s = queue.front();
        if (flag == 1){
    		ancestors_v1.push_back(s);
        }
    	else if(flag == 2){
    		ancestors_v2.push_back(s);
    	}
        queue.pop_front();
 
        // Get all adjacent vertices of the dequeued vertex s. If a adjacent has not been visited, then mark it visited and enqueue it
        for (i = transpose[s].begin(); i != transpose[s].end(); ++i){
            if (!visited[*i]){
                visited[*i] = true;
                queue.push_back(*i);
            }
        }
    }
}

/******************************************************************************************************************************
 * 
 * Functions to determine if the graph is cyclic or not
 * 
 ******************************************************************************************************************************/
bool Graph::isCyclicAuxiliar(int v, bool visited[], bool *recStack){
	if(visited[v] == false){
		// Mark the current node as visited and part of recursion stack
		visited[v] = true;
		recStack[v] = true;

		// Recur for all the vertices adjacent to this vertex
		list<int>::iterator i;
		for(i = adj[v].begin(); i != adj[v].end(); ++i){
			if(!visited[*i] && isCyclicAuxiliar(*i, visited, recStack))
				return true;
			else if(recStack[*i])
				return true;
		}

	}
	recStack[v] = false; // remove the vertex from recursion stack
	return false;
}

// Returns true if the graph contains a cycle, else false.
bool Graph::isCyclic(){
	// Mark all the vertices as not visited and not part of recursion stack
	bool *visited = new bool[V];
	bool *recStack = new bool[V];
	for(int i = 0; i < V; i++){
		visited[i] = false;
		recStack[i] = false;
	}

	// Call the recursive helper function to detect cycle in different DFS trees
	for(int i = 0; i < V; i++)
		if(isCyclicAuxiliar(i, visited, recStack))
			return true;

	return false;
}


/******************************************************************************************************************************
 * 
 * LCA: determines the lowest commons ancestor or ancestors from the list
 * 
 ******************************************************************************************************************************/
void Graph::LCA(list<int> common_ancestors){
	list<int>::iterator i;
	for (i = common_ancestors.begin(); i != common_ancestors.end(); i++){

		/*If vertex out_degree == 0 -> it doesnt have children. Therefore is a lca*/
		if(out_degree[*i] == 0){
			break;
		}
		else{
			list<int>::iterator it; 
			/*Checks if children exists in common_ancestor*/
			for(it = adj[*i].begin(); it != adj[*i].end(); it++){
				list<int>::iterator findChildren = find(common_ancestors.begin(), common_ancestors.end(), *it);
				/*If children exists in common_ancestors -> remove parent from list*/
				if(findChildren != common_ancestors.end()){
					common_ancestors.erase(i);
					common_ancestors.push_front(0); //solves size issues that leads to seg fault
					break;
				}	
			}	
		}
	}

	/*Sorts array*/
	common_ancestors.sort();
	
	/*Prints result*/
	for (auto it = common_ancestors.begin(); it != common_ancestors.end(); it++) {
    	if(*it != 0) //skips 0 values 
    		cout << *it << " ";
	}
	cout << endl;
}

/******************************************************************************************************************************
 * Auxiliar function to merge lists with the same common ancestors into one
 ******************************************************************************************************************************/
list<int> Graph::mergeLists(){
	ancestors_v1.sort();
	ancestors_v2.sort();

	list<int> common_ancestors;
	set_intersection(ancestors_v1.begin(), ancestors_v1.end(), ancestors_v2.begin(), ancestors_v2.end(), back_inserter(common_ancestors));

    return common_ancestors;
}

/******************************************************************************************************************************
 * 
 * MAIN
 * 
 ******************************************************************************************************************************/
int main(){
	int v1, v2;
    int n, m, x, y;
    int current = 0;
    int cnt = 1;
    assert(scanf("%d %d", &v1, &v2) > 0);
    assert(scanf("%d %d", &n, &m) > 0);
	
	/*Verifies input*/
    if(v1 < 1 || v1 > n){
    	cout << "0" << endl;
    	return 0;
    }
    if(v2 < 1 || v2 > n){
    	cout << "0" << endl;
    	return 0;
    }
    if(n < 1){
    	cout << "0" << endl;
    	return 0;
    }

	/* Create graph*/
	Graph g(n);


	for (int i = 0; i < m; i++){
        assert(scanf("%d %d", &x, &y) > 0);
        
        if(current == x){
        	cnt++;
        } else{
        	cnt = 1;
        }
		int error = g.addEdge(x, y, cnt);
		/*Node contains more than 2 parents*/
		if(error == -1){
			cout << "0" << endl;
			return 0;
		}
		current = x;
	}

	/*Verifies if there is a cyclic graph (if true, generates an invalid tree)*/
	if(g.isCyclic()){
		cout << "0" << endl;
		return 0;
	}
	

	/*BFS (flag = 1 for vertex 1, flag = 2 for vertex 2)*/
	g.BFS(v1, 1);
	g.BFS(v2, 2);

	/*Merge common ancestors in one list*/
	list<int> common_ancestors = g.mergeLists();

	/*No ancestors in common*/
	if(common_ancestors.empty()){
		cout << "-" << endl;
		return 0;
	} 
	else{
		g.LCA(common_ancestors);	
	}



	return 0;
}
