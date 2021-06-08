# -*- coding: utf-8 -*-
"""
Grupo tg011
Joana Mendonça 83597
Filipe Colaço 84715
"""

import numpy as np
import math

def createdecisiontree(D, Y, noise = False):
    d_trn = np.array(D) + 0
    y_trn = np.transpose(np.array(Y)) + 0
    
    # if tree is big enough split into training and testing sets
    if len(D) >= 8:
        # making sure both training and testing sets have equal amount of target values
        ids_0 = [i for i, x in enumerate(Y) if x == 0]
        ids_1 = [i for i, x in enumerate(Y) if x == 1]
        
        # defining training and testing sizes
        trn_0 = math.ceil(len(ids_0) * .75)
        tst_0 = len(ids_0) - trn_0
        trn_1 = math.ceil(len(ids_1) * .75)
        tst_1 = len(ids_1) - trn_1

        ids_trn = ids_0[:trn_0] + ids_1[:trn_1]
        ids_tst = ids_0[-tst_0:] + ids_1[-tst_1:]

        # dividing the dataset
        d_tst = np.array(d_trn)[ids_tst]
        y_tst = np.array(y_trn)[ids_tst]
        d_trn = np.array(d_trn)[ids_trn]
        y_trn = np.array(y_trn)[ids_trn]

    # create tree via ID3 algorithm
    tree = DTree(d_trn, y_trn, list(range(len(D[0]))), -1)

    # post pruning
    if len(D) >= 8:
        pruned = pruneTree(tree, d_tst, y_tst)
        # print(pruned)
        return pruned
    
    # print(tree)
    return tree

def DTree(D, Y, attrs, default):
    """
    Computes a decision tree given a training set [D, Y] using ID3 algorithm,
    with the help of entropy and information gain.
    """
    # if there's no data, just return the default passed down
    if len(D) == 0:
        return default
    
    # if target class only has one value present, either return the value
    # or, in case it's the first node, return the minimum tree
    if len(np.unique(Y)) == 1:
        if default != -1: return Y[0]
        else: return [0, Y[0], Y[0]]
    
    # if there are no attributes to expand the tree, return the most common target value
    if len(attrs) == 0:
        return np.argmax(np.bincount(Y))

    info_gains = D.shape[1] * [-10] # used to gather and compare info gains
    best_gain_index = -1            # index of attribute with best info gain
    children = [0, 0]               # this node's children

    # calculate info gain for every feature 'f'
    for f in attrs:
        info_gains[f] = infoGain(D[:,f], Y)

    # use the feature with the highest gain
    best_gain_index = info_gains.index(max(info_gains))
    m = np.argmax(np.bincount(Y))
    
    # separate the tree into two
    for value in range(2):
        # indexes of rows where the value of the best attribute matches 'value'
        ids = [i for i, x in enumerate(D[:,best_gain_index]) if x == value]

        children[value] = DTree(
            D[ids], Y[ids],
            list(filter(lambda a: a != best_gain_index, attrs)), m)

    # check if the two children are identical; if so, replace current node with a child
    if np.array_equal(np.array(children[0], dtype=object), np.array(children[1], dtype=object)):
        return children[0]
    
    return [best_gain_index] + children

def pruneTree(tree, Dtst, Ytst):
    """
    Performs pruning on the generated tree using Reduced-Error Pruning.
    This is a bottom-up recursive algorithm.
    """
    # check left node, then right node
    if isinstance(tree, list) and len(Dtst) > 0:
        # calculate subdataset by splitting by the current attribute
        for v in range(2):
            ids = [i for i, x in enumerate(Dtst[:,tree[0]]) if x == v]
            tree[v+1] = pruneTree(tree[v+1], Dtst[ids], Ytst[ids])

        # calculate the error of using the original node
        Y2 = checkTree(tree, Dtst)
        err_original = np.mean(np.abs(np.subtract(Y2, Ytst)))

        # calculate the error of only using the leaf node
        maj = np.argmax(np.bincount(Ytst))
        err_leaf = np.count_nonzero(Ytst != maj) / len(Ytst)
        
        # check who's best, the tree or the leaf
        if err_leaf < err_original: return maj
        else: return tree

    # it reached the recursion's end (leaf node)
    else: return tree

def entropy(Y):
    """ Calculates the entropy of a certain partition. """
    entropy = 0
    if len(Y) == 0: return 0

    for value in range(2):
        p = np.sum(Y == value) / len(Y)
        entropy -= p * math.log(p if p > 0 else 1, 2)
    
    return entropy

def infoGain(D, Y):
    """ Calculates the information gain of a certain partition. """
    gain = entropy(Y)
    for value in range(2):
        # get indexes of records where D (which is a single column) is 'value'
        ids = [i for i, x in enumerate(D) if x == value]
        gain -= (len(ids) / len(Y)) * entropy(Y[ids])
    
    return gain

def checkTree(tree, D):
    """ Classifies a dataset give a tree 'tree'. """
    D = np.array(D)
    output = []
    for record in D:
        r_tree = tree
        for ii in range(len(record)):
            if record[r_tree[0]]==0:
                if not isinstance(r_tree[1], list):
                    output += [r_tree[1]]
                    break
                else: r_tree = r_tree[1]
            else:
                if not isinstance(r_tree[2], list):
                    output += [r_tree[2]]
                    break
                else: r_tree = r_tree[2]
    return np.array(output)
