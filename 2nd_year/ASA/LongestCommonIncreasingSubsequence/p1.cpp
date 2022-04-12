/***********************************************************************************************************
 *                          ASA Projeto 1 - Grupo tp037
 *                             Joana Mendonca, 83597
 ***********************************************************************************************************/
#include <stdio.h>
#include <sstream>
#include <string>
#include <vector>
#include <iostream>
#include <ostream>
#include <algorithm>
#include <cctype>
#include <chrono>


using namespace std;
using namespace std::chrono;

int counter = 0;
int maxLength = 0;

/***********************************************************************************************************
 * PROBLEM 1: Longest Increasing Subsequence
 ***********************************************************************************************************/
int LIS(vector<int> X, int n){
  /*Base Case*/
  if (n == 0)
    return 0;
 
  /*Initialize length: stores the length of the LIS*/
  vector<int> length(n, 1);
 
  /*Initialize count: stores the count of the LIS*/
  vector<int> count(n, 1);
 
  for(int i = 0; i < n; i++){
    for(int j = 0; j < i; j++){
      /*Iterates over the values to the left of X[i] considering the ones that have smaller value*/
      if(X[i] > X[j]){
        /*Increments value of length when leq (increasing subsequence)*/
        if(length[i] <= length[j]){
          length[i] = length[j] + 1;
          count[i] = count[j];
        } 
        /*New increasing subsequence*/
        else if(length[i] == length[j]+1)
          count[i] += count[j];
      }
    }
  }

  /*Finds the maximum element in array length*/ 
  for (int i = 0; i < n; i++)
    if(length[i] > maxLength)
       maxLength = length[i];

  for(int i = 0; i < n; i++) {
    /*Adds the count value with maxLength to count the number of lis*/
    if(length[i] == maxLength)
      counter += count[i];
  }
  return(1);
}

/***********************************************************************************************************
 * PROBLEM 2: Longest Common Increasing Subsequence
 ***********************************************************************************************************/
int LCIS(vector<int> X, int n, vector<int> Y, int m){
  vector<int> length(m-1, 0);

  for(int i = 0; i < n; i++){
    /*Initialize current length of LCIS*/
    int current = 0;

    /*For each element of X[], traverse all elements of Y[]*/
    for (int j = 0; j < m; j++){
      if (X[i] == Y[j]){
        /*If both elements are common, increments the vector length*/
        if (current + 1 > length[j])
          length[j] = current + 1;
      }
      /* Seeks for previous smaller common element for current element of X */
      if (X[i] > Y[j])
        if (length[j] > current)
          current = length[j];
    }
  }

  maxLength = 0;
  /*Finds the maximum element in array length*/ 
  for (int i = 0; i < m; i++)
      if (length[i] > maxLength)
         maxLength = length[i];

  /*for (int i = 0; i < m; ++i){
    if(length[i] == maxLength)
      counter++;
  }*/

  return maxLength;
} 


/***********************************************************************************************************
 * MAIN
 ***********************************************************************************************************/
int main(){
  string aux;
  int problem;
  getline(cin, aux);
  problem = stoi(aux);
  /*****************************************************************************
   * Problem 1
   *****************************************************************************/ 
  if(problem == 1){
    string input;
    int N;
    int number;

    auto start = high_resolution_clock::now();
    /*Reads first line*/
    getline(cin, input);
    stringstream iss(input);

    vector<int> X;
    while (iss >> number)
      X.push_back(number);

    N = X.size();
   
    /*Function Call*/
    int result = LIS(X, N);
    if(result == 0 || result == 1) 
      cout << maxLength << ' ' << counter << endl;


    auto stop = high_resolution_clock::now();
    auto duration = duration_cast<microseconds>(stop - start);
    cout << "\nTime taken by function: " << duration.count() << " microseconds" << endl;

  }

  /*****************************************************************************
   * Problem 2
   *****************************************************************************/ 
  if(problem == 2){
    string input;
    int N, M;
    int number;


    auto start = high_resolution_clock::now();
    /*Reads first line*/
    getline(cin, input);
    stringstream iss(input);

    vector<int> X;
    while (iss >> number)
      X.push_back(number);

    N = X.size();
    /*for (int i = 0; i < N; ++i){
      cout << X.at(i) << endl;
    }*/

    /*Reads second line*/
    getline(cin, input);
    iss.clear();
    iss.str(input);

    vector<int> Y;
    while (iss >> number)
      Y.push_back(number);
    
    M = Y.size();
    /*for (int i = 0; i < M; ++i){
      cout << Y.at(i) << endl;
    }*/

    /*Call function*/
    int result = LCIS(X, N, Y, M);
    cout << result << endl;
    auto stop = high_resolution_clock::now();
    auto duration = duration_cast<microseconds>(stop - start);
    cout << "\nTime taken by function: " << duration.count() << " microseconds" << endl;

  }
}