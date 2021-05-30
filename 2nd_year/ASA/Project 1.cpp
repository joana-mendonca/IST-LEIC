/***********************************************************************************************
 *
 *                              PROJECT 1 
 *
 **********************************************************************************************/
#include <iostream>
#include<vector>
#include<cstring>
using namespace std;

int counter;
/***********************************************************************************************
 * 
 *                                     DFS FUNCTIONS
 * 
 **********************************************************************************************/

/* Function that runs DFS and stores the nodes visited */
void dfsVisit(int node, vector<int> graph[], bool visited[], int discovered[]) {
    /* Mark as visited */
    visited[node] = true;
    
    /* Traverse for all its children */
    for (auto const& i:graph[node]) { 
        /* If not visited*/
        if (!visited[i])
            dfsVisit(i, graph, visited, discovered);
    }
    /*Stores nodes visited*/
    discovered[counter] = node;
    counter--;
}

/* Function to traverse the DAG and find the longest path*/
void dfs(int node, vector<int> graph[], int path[], bool visited[]) {
    /* Mark as visited */
    visited[node] = true;
  
    /* Traverse for all its children */
    for (long unsigned int i = 0; i < graph[node].size(); i++) { 
        /* If not visited */
        if (!visited[graph[node][i]])
            dfs(graph[node][i], graph, path, visited);
  
        /* Store the max of the paths */
        path[node] = max(path[node], 1 + path[graph[node][i]]);
    }
}

/***********************************************************************************************
 * Function that returns minimum number of interventions required to assure all dominoes fall                                
 **********************************************************************************************/
int findMinimum(vector<int> graph[], int n){
    counter = n;
    bool visiting[n + 1];
    memset(visiting, false, sizeof visiting);
    int discovered[n + 1];
    memset(discovered, 0, sizeof discovered);
    
    /* Call DFS for every unvisited vertex */
    for (int i = 1; i < n + 1; i++) {
        if (!visiting[i]){
            dfsVisit(i, graph, visiting, discovered);
        }
    }

    bool visited[n + 1];
    memset(visited, false, sizeof visited);
    int path[n + 1];
    memset(path, 0, sizeof path);
    int minimum = 0;
    for(int i = 1; i < n + 1; i++){
        if(!visited[discovered[i]]){
            dfs(discovered[i], graph, path, visited);
            minimum++;
        }
    }
    return minimum;
}

/***********************************************************************************************
 * Function that returns the longest path
 **********************************************************************************************/
int findLongestPath(vector<int> graph[], int n) {
    int path[n + 1];
    memset(path, 0, sizeof path);
  
    /* Visitedited array to know if the node
     has been visitedited previously or not*/
    bool visited[n + 1];
    memset(visited, false, sizeof visited);
  
    /* Call DFS for every unvisited vertex */
    for (int i = 1; i < n + 1 ; i++) {
        if (!visited[i])
            dfs(i, graph, path, visited);
    }
  
    int maximum = 0;
    /* Traverse and find the maximum of all path[i] */
    for (int i = 1; i < n + 1; i++) {
        maximum = max(maximum, path[i]);
    }
    return maximum;
}
 
/***********************************************************************************************
 *
 *                                          MAIN
 * 
 **********************************************************************************************/  
int main() {
    int n, m;
    scanf("%d %d", &n, &m);
    vector<int> graph[n + 1];

    /*Create graph with given edges*/
    int u, v;
    for(int i = 0; i < m; i++) {
        scanf("%d %d", &u, &v);
        graph[u].push_back(v);
    }
    
    /*Print output*/
    cout << findMinimum(graph, n) << " " << findLongestPath(graph, n) + 1 << endl;
    
    return 0;
}
