# -*- coding: utf-8 -*-
"""

SAME LSTM NETWORK AS MATLAB

"""
# PYTORCH
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


# device config
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

# hyper parameters
input_size = 1
e_in_size = 1
d_in_size = 20
seq_len = 20
n_features = 1
hidden_size = 100
num_classes = 4
output_size = num_classes
epochs = 2
learning_rate = 0.0001



"""  DATA PROCESSING  """
batch_size = 1

class FBG_dataset(Dataset):
    
    def __init__(self, function):
        # data loading
        data = loadmat('labels_num.mat')
        xy = data[function]
        
        # split x, y
        self.x = torch.from_numpy(xy[:, 1:]).float()
        self.y = torch.from_numpy(xy[:, [0]]).long()
        self.y = self.y.view(-1)
        self.n_samples = xy.shape[0]
        
    def __getitem__(self, index):
        return self.x[index], self.y[index]
        
    def __len__(self):
        return self.n_samples
    

train_set = FBG_dataset("training")
train_loader = DataLoader(dataset=train_set, batch_size=batch_size, shuffle=True) #num_workers = 2 peta
valid_set = FBG_dataset("validation")
valid_loader = DataLoader(dataset=valid_set, batch_size=batch_size, shuffle=True) #num_workers = 2 peta

# print data information
examples = iter(train_loader)
samples, labels = examples.next()
samples = samples.view(batch_size, 20,-1)
print(samples)
print(samples.shape)
print(labels)



#%% NETWORK CONFIGURATION

class Encoder(nn.Module):
    def __init__(self, seq_len, n_features, embedding_dim=64):
        super(Encoder, self).__init__()
        
        self.seq_len = seq_len
        self.n_features = n_features
        self.embedding_dim = embedding_dim
        self.hidden_dim = embedding_dim*2
        
        self.lstm1 = nn.LSTM(
            input_size=n_features,
            hidden_size = self.hidden_dim,
            num_layers=1,
            batch_first=True)
        
        self.lstm2 = nn.LSTM(
            input_size=self.hidden_dim,
            hidden_size = embedding_dim,
            num_layers=1,
            batch_first=True)
        
    def forward(self, x):
        x = x.view(1, self.seq_len, self.n_features)
        
        x, (hidden_n, cell_n) = self.lstm1(x)
        x, (hidden_n, cell_n) = self.lstm2(x)
        
        return hidden_n.view(1, self.embedding_dim)


class Decoder(nn.Module):

  def __init__(self, seq_len, input_dim=64, n_features=1):
    super(Decoder, self).__init__()

    self.seq_len, self.input_dim = seq_len, input_dim
    self.hidden_dim, self.n_features = 2 * input_dim, n_features

    self.rnn1 = nn.LSTM(
      input_size=input_dim,
      hidden_size=input_dim,
      num_layers=1,
      batch_first=True
    )

    self.rnn2 = nn.LSTM(
      input_size=input_dim,
      hidden_size=self.hidden_dim,
      num_layers=1,
      batch_first=True
    )

    self.l1 = nn.Linear(self.hidden_dim, n_features)
    self.l2 = nn.Linear(20, 4)

  def forward(self, x):
    x = x.repeat(self.seq_len, self.n_features)
    x = x.reshape((self.n_features, self.seq_len, self.input_dim))

    x, (hidden_n, cell_n) = self.rnn1(x)
    x, (hidden_n, cell_n) = self.rnn2(x)
    x = x.reshape((self.seq_len, self.hidden_dim))

    x = self.l1(x)
    x = self.l2(x.view(1,-1))
        
    return F.softmax(x, dim = 1)


class RecurrentAutoencoder(nn.Module):

  def __init__(self, seq_len, n_features, embedding_dim=64):
    super(RecurrentAutoencoder, self).__init__()

    self.encoder = Encoder(seq_len, n_features, embedding_dim).to(device)
    self.decoder = Decoder(seq_len, embedding_dim, n_features).to(device)

  def forward(self, x):
    x = self.encoder(x)
    x = self.decoder(x)

    return x


model = RecurrentAutoencoder(seq_len, n_features, 128)
model = model.to(device)





#%%
# Loss and optimizer
optimizer = torch.optim.Adam(model.parameters(), lr=1e-3)
criterion = nn.CrossEntropyLoss()


# Training loop

for epoch in range(epochs):
    for i, (strains, labels) in enumerate(train_loader):
        strains, labels = strains.to(device), labels.view(-1).to(device)    
        
        #forward pass
        out = model(strains)
        loss = criterion(out, labels)

        # backward and optimize
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

print("FIN ENTRENAMIENTO")

#%%

n_correct = 0
n_samples = 0
with torch.no_grad():
    model.eval()
        
    for i, (strains, labels) in enumerate(valid_loader):
    
        strains, labels = strains.to(device), labels.view(-1).to(device) 
                              
        output = model(strains)
            
        _, predicted = torch.max(output.data, 1)
        n_samples += labels.size(0)
        n_correct += (predicted == labels).sum().item()
    
acc = 100.0 * n_correct / n_samples
print(f'Accuracy of the network on the {n_samples} test strains: {acc:.2f} %')
