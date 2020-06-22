""" LSTM EXAMPLE: 
    https://pytorch.org/tutorials/beginner/nlp/sequence_models_tutorial.html  """

#%%

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


torch.manual_seed(1)


#%%

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

sample = samples[0].view(1,-1)
print(sample.shape)

#%%

in_dim = 3
out_dim = 3
seq_len = 5

lstm = nn.LSTM(in_dim, out_dim)  # Input dim is 3, output dim is 3
inputs = [torch.randn(1, in_dim) for _ in range(seq_len)]  # make a sequence of length 5
print("INPUTS: ", inputs)
# initialize the hidden state.
hidden = (torch.randn(1, 1, out_dim),
          torch.randn(1, 1, out_dim))
for i in inputs:
    # Step through the sequence one element at a time.
    # after each step, hidden contains the hidden state.
    out, hidden = lstm(i.view(1, 1, -1), hidden)

"""
 alternatively, we can do the entire sequence all at once.
 the first value returned by LSTM is all of the hidden states throughout
 the sequence. the second is just the most recent hidden state
 (compare the last slice of "out" with "hidden" below, they are the same)
 The reason for this is that:
 "out" will give you access to all hidden states in the sequence
 "hidden" will allow you to continue the sequence and backpropagate,
 by passing it as an argument  to the lstm at a later time
 Add the extra 2nd dimension
"""

inputs = torch.cat(inputs).view(len(inputs), 1, -1)
hidden = (torch.randn(1, 1, out_dim), torch.randn(1, 1, out_dim))  # clean out hidden state
out, hidden = lstm(inputs, hidden)
print("Out LSTM", out)
print("Hidden state: ", hidden)

#%%

"""  PREPARE DATA  """
def prepare_sequence(seq, to_ix):
    idxs = [to_ix[w] for w in seq]
    return torch.tensor(idxs, dtype=torch.long)


training_data = [
    ("The dog ate the apple".split(), ["DET", "NN", "V", "DET", "NN"]),
    ("Everybody read that book".split(), ["NN", "V", "DET", "NN"])
]
word_to_ix = {}
for sent, tags in training_data:
    for word in sent:
        if word not in word_to_ix:
            word_to_ix[word] = len(word_to_ix)
print(word_to_ix)
tag_to_ix = {"DET": 0, "NN": 1, "V": 2}

# These will usually be more like 32 or 64 dimensional.
# We will keep them small, so we can see how the weights change as we train.
EMBEDDING_DIM = 6
HIDDEN_DIM = 6

#%%

"""  CREATE MODEL  """
class LSTMTagger(nn.Module):

    def __init__(self, embedding_dim, hidden_dim, vocab_size, tagset_size):
        super(LSTMTagger, self).__init__()
        self.hidden_dim = hidden_dim

        self.word_embeddings = nn.Embedding(vocab_size, embedding_dim)

        # The LSTM takes word embeddings as inputs, and outputs hidden states
        # with dimensionality hidden_dim.
        self.lstm = nn.LSTM(embedding_dim, hidden_dim)

        # The linear layer that maps from hidden state space to tag space
        self.hidden2tag = nn.Linear(hidden_dim, tagset_size)

    def forward(self, sentence):
        embeds = self.word_embeddings(sentence)
        lstm_out, _ = self.lstm(embeds.view(len(sentence), 1, -1))
        tag_space = self.hidden2tag(lstm_out.view(len(sentence), -1))
        tag_scores = F.log_softmax(tag_space, dim=1)
        return tag_scores
    
#%%

"""  TRAIN THE MODEL  """
model = LSTMTagger(EMBEDDING_DIM, HIDDEN_DIM, len(word_to_ix), len(tag_to_ix))
loss_function = nn.NLLLoss()
optimizer = optim.SGD(model.parameters(), lr=0.1)

# See what the scores are before training
# Note that element i,j of the output is the score for tag j for word i.
# Here we don't need to train, so the code is wrapped in torch.no_grad()
with torch.no_grad():
    inputs = prepare_sequence(training_data[0][0], word_to_ix)
    tag_scores = model(inputs)
    print(tag_scores)

for epoch in range(300):  # again, normally you would NOT do 300 epochs, it is toy data
    for sentence, tags in training_data:
        # Step 1. Remember that Pytorch accumulates gradients.
        # We need to clear them out before each instance
        model.zero_grad()

        # Step 2. Get our inputs ready for the network, that is, turn them into
        # Tensors of word indices.
        sentence_in = prepare_sequence(sentence, word_to_ix)
        targets = prepare_sequence(tags, tag_to_ix)

        # Step 3. Run our forward pass.
        tag_scores = model(sentence_in)

        # Step 4. Compute the loss, gradients, and update the parameters by
        #  calling optimizer.step()
        loss = loss_function(tag_scores, targets)
        loss.backward()
        optimizer.step()

# See what the scores are after training
with torch.no_grad():
    inputs = prepare_sequence(training_data[0][0], word_to_ix)
    tag_scores = model(inputs)

    # The sentence is "the dog ate the apple".  i,j corresponds to score for tag j
    # for word i. The predicted tag is the maximum scoring tag.
    # Here, we can see the predicted sequence below is 0 1 2 0 1
    # since 0 is index of the maximum value of row 1,
    # 1 is the index of maximum value of row 2, etc.
    # Which is DET NOUN VERB DET NOUN, the correct sequence!
    print(tag_scores)