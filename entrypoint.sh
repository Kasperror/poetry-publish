#!/bin/bash +x

set -e
set -x

cd ${13}
echo "Updating&Upgrading the system"
if [ -n "${11}" ]; then
  apt-get update
  apt-get -y upgrade
  apt-get -y install --no-install-recommends ${11}
fi

if [ $1 != 'latest' ]; then
  echo "Creating pyenv for python version $1"
  pyenv install $1
  pyenv global $1
  pyenv rehash
fi

if [ -z $8 ]; then
  pre=""
else
  pre="--pre"
fi

echo "Installing poetry - version $2"
if [ $2 != 'latest' ]; then
  pip install poetry$2 $pre
else
  pip install poetry $pre
fi

if [ -n "${12}" ]; then
  poetry self add ${12}
fi

if [ -n "${15}" ]; then
  IFS=','
  for arg in ${15}; do
    IFS=' '
    # Trim spaces around the argument
    arg=$(echo "$arg" | xargs)
    # Dynamically split the argument into parts
    read -r -a parts <<< "$arg"
    # Pass all parts dynamically to poetry config
    echo "Adding config: ${parts[*]}"
    poetry config "${parts[@]}"
  done
  IFS=' '
fi


if [ -n "${16}" ]; then
  IFS=','  # Set IFS to comma for task2
  for arg in ${16}; do
    IFS=' '
    # Split each argument further using whitespace as a delimiter
    read -r name url <<<"$(echo "$arg" | xargs)"
    echo "Adding source: $name with URL: $url"
    poetry source add "$name" "$url"
  done
  IFS=' '
fi


echo "Running poetry install"
poetry install ${7}

echo "Running poetry build"
if [ -z $6 ]; then
  poetry build
else
  poetry build --format $6
fi

if [ -z $4 ] || [ -z $5 ]; then
  poetry config pypi-token.pypi $3
  poetry publish ${14}
else
  if [ -z $9 ] || [ -z ${10} ]; then
    poetry config pypi-token.$4 $3
    poetry config repositories.$4 $5
    poetry publish --repository $4  ${14}
  else
    poetry config repositories.$4 $5
    poetry publish --repository $4 --username $9 --password ${10}  ${14}
  fi
fi
