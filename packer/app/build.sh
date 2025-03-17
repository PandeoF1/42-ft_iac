set -e
RAND=$RANDOM
echo "Building image with tag: docker.io/pandeo/ft-iac:$RAND"
docker build . -t docker.io/pandeo/ft-iac:$RAND
echo "Pushing image to docker.io"
docker push docker.io/pandeo/ft-iac:$RAND
echo "Done"
