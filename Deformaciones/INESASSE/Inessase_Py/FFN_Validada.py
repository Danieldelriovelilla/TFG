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
input_size = 20
hidden_size = 100
num_classes = 4
epochs = 20
learning_rate = 0.0001



"""  DATA PROCESSING  """
batch_size = 64

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
train_loader = DataLoader(dataset=train_set, batch_size=4, shuffle=True) #num_workers = 2 peta
valid_set = FBG_dataset("validation")
valid_loader = DataLoader(dataset=valid_set, batch_size=4, shuffle=True) #num_workers = 2 peta

# print data information
examples = iter(train_loader)
samples, labels = examples.next()
print(samples.shape, labels.shape)

#%%

"""  NEURAL NETWORK DEFINITION  """
class NeuralNet(nn.Module):
    def __init__(self, input_size, hidden_size, num_classes):
        super(NeuralNet, self).__init__()
        self.l1 = nn.Linear(input_size, 128)
        self.l2 = nn.Linear(128, hidden_size)
        self.l3 = nn.Linear(hidden_size, hidden_size)
        self.l4 = nn.Linear(hidden_size, num_classes)
        self.relu = nn.ReLU()
        self.sigm = nn.Sigmoid()
        self.dropout = nn.Dropout(p=0.2)
        
    def forward(self, x):
        x = self.l1(x)
        x = self.sigm(x)
        x = self.dropout(self.l2(x))
        x = self.sigm(x)
        x = self.dropout(self.l3(x))
        x = self.relu(x)
        out = self.l4(x)
        return out
    

model = NeuralNet(input_size, hidden_size, num_classes).to(device)


""" LOAD MODEL  """
"""
#state_dict = torch.load('FBG_Prueba.pth')
#print(state_dict.keys())
#model.load_state_dict(state_dict)
"""

# loss and optimizer
criterion = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)



""" TRAINING SETUP  """
n_total_steps = len(train_loader)


for epoch in range(epochs):
    for i, (strains, labels) in enumerate(train_loader):
        strains, labels = strains.to(device), labels.view(-1).to(device)    
        print("strains shape", strains.shape)
        #forward pass
        out = model(strains)
        print('OUT', out)
        print('LABELS', labels)
        loss = criterion(out, labels)
        print('LOSS', loss)

        # backward and optimize
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        """
        if (i+1) % 200 == 0:
            print (f'Epoch [{epoch+1}/{epochs}], Step [{i+1}/{n_total_steps}], Loss: {loss.item():.4f}')
        """
    # Test the model
    # In test phase, we don't need to compute gradients (for memory efficiency)
    with torch.no_grad():
        model.eval()
        n_correct = 0
        n_samples = 0
        for strains, labels in valid_loader:
            strains, labels = strains.to(device), labels.view(-1).to(device)       
            out = model(strains)
            # max returns (value ,index)
            _, predicted = torch.max(out.data, 1)
            n_samples += labels.size(0)
            n_correct += (predicted == labels).sum().item()
    
        acc = 100.0 * n_correct / n_samples
        print(f'Accuracy of the network on the {n_samples} test strains: {acc:.2f} %')
    print (f'Epoch [{epoch+1}/{epochs}]')
    

"""  SAVE THE MODEL  """
#torch.save(model.state_dict(), 'FBG_Prueba.pth')


# PLOT A SAMPLE
"""
ps = model(strains[0])
fig, ax = plt.subplots()
x = torch.tensor([1, 2, 3, 4]).detach().numpy()
y =  ps.squeeze().detach().numpy()
plt.bar(x, y)
plt.xticks(x, ('D01', 'D04', 'D14', 'Und'))
plt.show()
"""