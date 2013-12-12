Templates and scripts are modifications of those that were delivered with
[bosh-lite](http://github.com/cloudfoundry/bosh-lite) which were based
on those from https://github.com/misheska/basebox-packer.

##Build the boxes

A GNU makefile is provided to support automated builds.  It assumes
that both GNU Make and Packer are in the PATH.  Download and install
Packer from <http://www.packer.io/downloads.html>

To build all boxes:

    make

Or, to build one box:

```bash
    $ make list
    vmware/ci_with_warden_prereqs.box
    virtualbox/ci_with_warden_prereqs.box

    $ # Choose a definition, like 'vmware/ci_with_warden_prereqs.box'
    $ vmware/ci_with_warden_prereqs.box
```

##Using the boxes

After you've built your box, you can copy the desired box to ~/boxes and
follow the [testing](https://github.com/cloudfoundry/warden/blob/master/README.md#testing)
instructions from the warden project.

