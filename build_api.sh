# First we need to collect our custom Widdershins install
git clone https://github.com/Sponsus/widdershins.git _shins

echo 'Installing NPM deps'

cd _shins
npm install
cd ../

echo 'Running API doc builder'

node _shins/widdershins.js --search true --language_tabs 'python:Python' --summary spec/openapi3.yaml -o source/api_spec.html.md

echo 'Cleaning up generated Markdown'
sed -i '1,34d' source/api_spec.html.md

echo 'Merging files...'
cp -f source/guides.md source/index.html.md

cat source/pre_ref.md >> source/index.html.md

cat source/api_spec.html.md >> source/index.html.md

# Clean up the shins install
echo 'Cleaning up...'
rm -rf _shins
echo 'Widdershins install removed'