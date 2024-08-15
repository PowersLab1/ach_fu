#!/bin/sh
if [ "$#" -ne 1 ]; then
    echo ""
    echo "Usage: sh deploy_task.sh REPOSITORY"
    echo "Make sure to run this script in the parent directory of the repository."
    exit
fi

TRIMMED=$(echo $1 | sed 's:/*$::')

cd $TRIMMED
if [ $? -ne 0 ]; then
    echo ""
    echo "Repository named $1 not found in current directory."
    echo "Make sure to run this script in the parent directory of the repository."
    exit 1
fi

git update-index --refresh
git diff-index --quiet HEAD --
if [ $? -ne 0 ]; then
    printf "\nRepository contains uncommitted changes. Commit changes first.\n\n"
    exit 2
fi

echo "Pulling git repository for recent changes..."
git pull origin master &> /dev/null
if [ $? -ne 0 ]; then
    printf "\nRepository contains uncommitted changes. Commit changes first.\n\n"
    exit 2
fi

echo "Pushing git repository..."
git push origin master &> /dev/null
if [ $? -ne 0 ]; then
    printf "\ngit push failed. Aborting...\n\n"
    exit 3
fi

echo "Deploying to gh-pages..."
npm run deploy &> /dev/null
if [ $? -ne 0 ]; then
    printf "\nnpm run deploy failed. Aborting...\n\n"
    exit 4
fi

echo "Deploying to spinup..."
RESULT=$(curl --silent -X POST -H "Content-Type: application/json" -d '{
	"task": "'"$TRIMMED"'",
  "key": "45a657ad-1080-4e9d-a0b4-46e28cb51687"
}' https://powerslab.research.yale.edu/api/deploy)

if [[ "$RESULT" == *"Updating"* ]]; then
  printf "\n\n"
  echo "=========================="
  echo "         SUCCESS!         "
  echo "=========================="
  printf "\n\n"
  exit 0
elif [[ "$RESULT" == *"Already"* ]]; then
  printf "\nSpinup was already up to date. Nothing new was deployed.\n\n"
  exit 0
fi

printf "\n\nDeploy to spinup failed. You should ssh to the spinup and run git pull.\n\n"
