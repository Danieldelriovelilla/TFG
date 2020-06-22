"""  LSTM TEST  """

import torch
import torchvision
from torch.utils.data import Dataset, DataLoader
# paquetes para definir la red
from torch import nn
import torch.nn.functional as F
# paquetes para entrenar la red
from torch import optim
# matematicas
import numpy as np
import math
# paquetes para abrir archivos .mat
import scipy.io
from scipy.io import loadmat
# otros
from collections import Counter
import matplotlib.pyplot as plt

torch.manual_seed(2) # so that random variables will be consistent and repeatable for testing

#%%

# define an LSTM with an input dim of 4 and hidden dim of 3
# this expects to see 4 values as input and generates 3 values as output
input_dim = 1
hidden_dim = 1

lstm = nn.LSTM(input_size=input_dim, hidden_size=hidden_dim)  

# make 5 input sequences of 4 random values each
# 1 batch of 5 sequences
inputs_list = [torch.randn(1, input_dim) for _ in range(5)]

print('inputs: \n', inputs_list)
print('\n')

# initialize the hidden state
# (1 layer, 1 batch_size, 3 outputs)
# first tensor is the hidden state, h0
# second tensor initializes the cell memory, c0
h0 = torch.randn(1, 1, hidden_dim)
c0 = torch.randn(1, 1, hidden_dim)

# step through the sequence one element at a time.
for i in inputs_list:
    
    # after each step, hidden contains the hidden state
    out, hidden = lstm(i.view(1, 1, -1), (h0, c0))
    
    print('out: \n', out)
    print('hidden: \n', hidden)
    print('\n')



#%%

barch_size = 1
#inputs_list = [torch.randn(barch_size, input_dim) for _ in range(5)]


# turn inputs into a tensor with 5 rows of data
# add the extra 2nd dimension (1) for batch_size
inputs = torch.cat(inputs_list).view(len(inputs_list), barch_size, -1)


# print out our inputs and their shape
# you should see (number of sequences, batch size, input_dim)
print('inputs size: \n', inputs.size())
print('\n')

print('inputs: \n', inputs)
print('\n')


## initialize the hidden state
#h0 = torch.randn(1, barch_size, hidden_dim)
#c0 = torch.randn(1, barch_size, hidden_dim)


# get the outputs and hidden state
out, (hidden, cell) = lstm(inputs, (h0, c0))


print('out: \n', out)
print(out.shape)
print('hidden: \n', hidden)
