import torch
use_cuda = torch.cuda.is_available()

print(f">>> GPU status: {use_cuda}")
