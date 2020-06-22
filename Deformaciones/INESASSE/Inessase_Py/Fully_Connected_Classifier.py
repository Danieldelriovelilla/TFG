import scipy.io
import numpy as np
from scipy.io import loadmat
# PyTorch packages
import torch
from torch import nn
import torch.nn.functional as F
from torch import optim


# Load data and label it
strains = loadmat('py_data.mat')
variables = list(strains.keys())
print(strains.keys())
#print(variables)

it = 0
for key in variables:
    del strains[key]
    it += 1
    if it == 3:
        break


# Store the strains inside the train, test and validation tensors
# training_set = []
D01_tr = torch.from_numpy(strains["D01_Tr"]).float()
labels_d01 = torch.tensor([1]).unsqueeze(0).repeat(1,D01_tr.shape[0])
D04_tr = torch.from_numpy(strains["D04_Tr"]).float()
labels_d04 = torch.tensor([2]).unsqueeze(0).repeat(1,D04_tr.shape[0])
D14_tr = torch.from_numpy(strains["D14_Tr"]).float()
labels_d14 = torch.tensor([3]).unsqueeze(0).repeat(1,D14_tr.shape[0])
Und_tr = torch.from_numpy(strains["Und_Tr"]).float()
labels_und = torch.tensor([4]).unsqueeze(0).repeat(1,Und_tr.shape[0])

# validation set
D01_te = torch.from_numpy(strains["D01_Val"]).float()
labels_te = torch.tensor([1]).unsqueeze(0).repeat(1,D01_te.shape[0])
D04_te = torch.from_numpy(strains["D04_Val"]).float()
labels_te = torch.cat((labels_te, torch.tensor([2]).unsqueeze(0).repeat(1,D04_te.shape[0])), 1)
D14_te = torch.from_numpy(strains["D14_Val"]).float()
labels_te = torch.cat((labels_te, torch.tensor([3]).unsqueeze(0).repeat(1,D14_te.shape[0])), 1)
Und_te = torch.from_numpy(strains["Und_Val"]).float()
labels_te = torch.cat((labels_te, torch.tensor([4]).unsqueeze(0).repeat(1,Und_te.shape[0])), 1).view(-1)


# Reshape los tensores
Strains_tr = torch.cat((D01_tr, D04_tr, D14_tr, Und_tr), 0)
labels_tr = torch.cat((labels_d01, labels_d04, labels_d14, labels_und), 1).view(-1)
Strains_te = torch.cat((D01_te, D04_te, D14_te, Und_te), 0)

print("Strains training: ", Strains_tr.shape)
print("Labels training: ", labels_tr.shape)
print("Strains training: ", Strains_te.shape)
print("Labels test: ", labels_te.shape)

strains_tr = torch.zeros((Strains_tr.shape[0], 1, Strains_tr.shape[1]))
for i in range(Strains_tr.shape[0]):
    strains_tr[i] = Strains_tr[i]
strains_te = torch.zeros((Strains_te.shape[0], 1, Strains_te.shape[1]))
for i in range(Strains_te.shape[0]):
    strains_te[i] = Strains_te[i]

print("Strains training: ", strains_tr.shape)



# Generate the batches
"""
r=torch.randperm(strains_tr.shape[0])
strains_tr = strains_tr[r[:, None]]
labels_tr = labels_tr[r[:, None]]
"""
# FEED FORDARD MODEL
class Classifier(nn.Module):
    def __init__(self):
        super().__init__()
        self.fc1 = nn.Linear(20, 128)
        self.fc2 = nn.Linear(128, 128)
        self.fc3 = nn.Linear(128, 64)
        self.fc4 = nn.Linear(64, 4)

        # Dropout module with 0.2 drop probability
        self.dropout = nn.Dropout(p=0.2)

    def forward(self, x):
        # make sure input tensor is flattened
        x = x.view(x.shape[0], -1)

        # Now with dropout
        x = self.dropout(F.relu(self.fc1(x)))
        x = self.dropout(F.relu(self.fc2(x)))
        x = self.dropout(F.relu(self.fc3(x)))

        # output so no dropout here
        x = F.log_softmax(self.fc4(x), dim=1)

        return x


# OPTIMIZATION ALGORITHM
model = Classifier()
criterion = nn.NLLLoss()
optimizer = optim.Adam(model.parameters(), lr=0.003)

epochs = 1
steps = 0

batch_size = 1

train_losses, test_losses = [], []

"""
for e in range(epochs):
    running_loss = 0
    for i in range(0,strains_tr.shape[0], batch_size):
        optimizer.zero_grad()

        # Mucho cuidado con las dimensiones de los tensores
        batch_x = strains_tr[i:i+batch_size]
        batch_y = labels_tr[i:i+batch_size]
        
        log_ps = model(batch_x)
        loss = criterion(log_ps, batch_y)
        loss.backward()
        optimizer.step()

        running_loss += loss.item()
"""
"""
    else:
        test_loss = 0
        accuracy = 0

        # Turn off gradients for validation, saves memory and computations
        with torch.no_grad():
            model.eval()
            for images, labels in testloader:
                log_ps = model(images)
                test_loss += criterion(log_ps, labels)

                ps = torch.exp(log_ps)
                top_p, top_class = ps.topk(1, dim=1)
                equals = top_class == labels.view(*top_class.shape)
                accuracy += torch.mean(equals.type(torch.FloatTensor))

        model.train()

        train_losses.append(running_loss / len(trainloader))
        test_losses.append(test_loss / len(testloader))

        print("Epoch: {}/{}.. ".format(e + 1, epochs),
              "Training Loss: {:.3f}.. ".format(train_losses[-1]),
              "Test Loss: {:.3f}.. ".format(test_losses[-1]),
              "Test Accuracy: {:.3f}".format(accuracy / len(testloader)))
"""
print("Fin entrenamiento")

print(strains_tr[6055])
print(labels_tr[6055])
print(strains_tr[6056].shape)
print(labels_tr[6056])
print(strains_tr[6057].shape)
print(labels_tr[6057])
#print("model out: ",(model(batch_x)))

# pueba individual
"""
log_ps = model(strains_te[0:1])
print(log_ps)
print(labels_tr[0:1].view(1))
loss = criterion(log_ps, labels_tr[0:1].view(1))
"""