
## github push issue

- if `git push -u origin BRANCH_NAME` returns this error : 

```
error: RPC failed; HTTP 400 curl 22 The requested URL returned error: 400
send-pack: unexpected disconnect while reading sideband packet
```

- then try again after running this command :
 
`git config --global http.postBuffer 157286400`
