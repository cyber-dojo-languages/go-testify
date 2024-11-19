#!/bin/bash -Eeu

# We used to be able to install testify and its dependencies with go get, but this usage has been deprecated in favour of 
# go install.
# However, due to the presence of an exclude directive in testify's go.mod file, we can't simply use go install normally.
# (At least I haven't found a way to do it!)
# We can clone the testify github repo and install it/download dependencies that way (as below).
# BUT the dependencies are downloaded to the pkg/mod directory, rather than src, which is where go seems to be looking for them
# in the tests. We therefore do some very awkward jiggery pokery to move the dependencies to the src directory, and also 
# remove the version numbers from the directory names, since they are downloaded with them but go does not understand them
# when importing.

apk add build-base
mkdir -p src/github.com/stretchr
cd src/github.com/stretchr
git clone https://github.com/stretchr/testify.git --branch v1.9.0
cd testify
go install github.com/stretchr/testify
go mod download

# Move the dependencies to the src directory
cd ../../../..
mv src/github.com .
for folder in $(ls pkg/mod ); do 
    if [ $folder == "cache" ]; then
        continue
    else
        mv pkg/mod/$folder src
    fi
done

mv github.com/stretchr/testify src/github.com/stretchr

# Remove the version numbers from the directory names
cd src/
for folder in $(ls); do
    cd $folder
    for f in $(ls); do
        # In src/gopkg.in there is only one directory, which is the one we need to remove the version number from; in src/github.com,
        # there are multiple directories (and the version number needs to be removed from the sub-directory within each of these).
        if [ $folder == "github.com" ]; then
            cd $f
        fi
        for inner in $(ls); do
            new_name=${inner%@*}
            if [ $new_name != $inner ]; then
                mv $inner $new_name 
            fi
        done
        if [ $folder == "github.com" ]; then
            cd ..
        fi
    done
    cd ..
done
