# Syncing AWS storage

## From AWS to local machine

```
aws-kiste $ ssh jtoth@10.39.225.112 "tar cf - ~/Code/fast-llvm/" | tar xpf - -C aws_backup/fast-llvm/
```
