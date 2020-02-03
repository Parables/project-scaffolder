#!/bin/bash

# Global variables
projectDir='/home/parables/Workspace';
# formatting variables
q='\e[96m|-- ? ';
l='\e[96m|';
i='\e[96m|-- < ';
r='\e[34m';
nf='\e[0m';
o='         |-- ';

# Prints out a Star bordered text
printStars(){
    printf "\e[95m\n****************************************************\n"
    printf   "** \e[1m$1 **\n"
    printf "****************************************************\e[0m\n"
}

# Creates a new Svelte Project with Parcel
svelte_with_parcel(){ # $1 is the projectName
    printStars "Setting up your Svelte Project with Parcel"
    mkdir  $projectDir/Svelte/$projectName && cd $projectDir/Svelte/$projectName;
    echo "Directory created"
    printStars "Initialising yarn";
    yarn init -y;
    
    printStars "Adding scripts the package.json file"
    sed -i '/"license": "MIT"/a\
		,"scripts": {\
		"start": "parcel src/index.html --port 3000",\
		"build": "rm -rf dist && parcel build src/index.html --no-source-maps"\
		},\
		"browserslist": [\
		"last 1 chrome versions"\
    ]' package.json;
    
    printStars "Adding Parcel and Svelte plugins"
    yarn add -D parcel-bundler svelte parcel-plugin-svelte;
    
    printStars "Setting up project structure";
    mkdir  $projectDir/Svelte/$1/src && cd $projectDir/Svelte/$1/src;
    touch index.html && printf '<!DOCTYPE html>
		<html lang="en">
		<head>
		<meta charset="utf-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1.0" />
		<meta http-equiv="X-UA-Compatible" content="ie=edge" />
		<title>My App</title>
		</head>

		<body>
		<script defer src="./main.js"></script>
		<noscript>You need to enable JavaScript to run this app.</noscript>
		</body>
		</html>
    ' >> index.html;
    
    touch main.js && printf "import App from './App.svelte';

		const app = new App({
		target: document.body
		});

		export default app;
    " >> main.js ;
    
    touch App.svelte && printf '<script>
		let name = "friend";
		</script>

		<h1>Hello {name}!</h1>
    ' >> App.svelte;
    
    printStars "Starting up  your editor & app"
    code -n  $projectDir/Svelte/$1/
    yarn start;
    parcel index.html --port 3000;
}

# Creates a new Svelte Project with Rollup (default)
svelte_with_rollup(){ # $1 is the projectName
    cd $projectDir/Svelte;
    npx degit sveltejs/template $1
    cd  $1
    printStars "Installing dependencies"
    npm install
    read -e -p "Do you want to add TailwindCss(Y/n)? :   " -i "Y" choice ;printf $nf;
    if [  $choice != "No"  ] ||  [ $choice != "nO"  ] || [ $choice != "n" ]  ||  [ $choice != "NO"   ]; then
        printStars "Adding TailwindCss"
        npm i -D @fullhuman/postcss-purgecss postcss postcss-load-config svelte-preprocess tailwindcss
        npx tailwind init
        
        touch postcss.config.js  && printf	"
      const purgecss = require('@fullhuman/postcss-purgecss')({
            content: [
              './src/**/*.html',
              './src/**/*.svelte'
            ],
            whitelistPatterns: [/svelte-/],
            defaultExtractor: content => content.match(/[A-Za-z0-9-_:/]+/g) || []
			});

			const production = !process.env.ROLLUP_WATCH

			module.exports = {
            plugins: [
              require('tailwindcss'),
              ...(production ? [purgecss] : [])
            ]
      };" >> postcss.config.js;
        
        touch src/Tailwindcss.svelte  && printf "<style global>
		@tailwind base;
		@tailwind components;
		@tailwind utilities;
        </style>" >>  src/Tailwindcss.svelte;
        
        sed -i "/<script>/a\
        import Tailwindcss from './Tailwindcss.svelte';" src/App.svelte;
        
        sed -i "/<main>/a\
        <Tailwindcss />" src/App.svelte;
        
        sed -i "/import svelte from 'rollup-plugin-svelte';/a\
        import sveltePreprocess from 'svelte-preprocess'" rollup.config.js;
        
        sed -i "/svelte({/a\
        preprocess: sveltePreprocess({ postcss: true })," rollup.config.js;
    fi;

printStars "Adding extra dependencies"
	npm i --save-dev prettier prettier-plugin-svelte eslint eslint-plugin-svelte3 

touch .eslintrc.json && printf '{
  "env": {
    "browser": true,
    "es6": true
  },
  "parserOptions": {
    "ecmaVersion": 2019,
    "sourceType": "module"
  },
  "plugins": ["svelte3"],
  "extends": ["eslint:recommended"],
  "overrides": [
    {
      "files": ["**/*.svelte"],
      "processor": "svelte3/svelte3"
    }
  ],
  "rules": {
    "prettier/prettier": "error",
    "svelte3/lint-template": 2
  }
}' >> .eslintrc.json
   
touch  .prettierrc.json && printf '{
  "tabWidth": 2,
  "semi": true,
  "singleQuote": true,
  "plugins": ["prettier-plugin-svelte"],
  "svelteSortOrder": "styles-scripts-markup",
  "svelteStrictMode": true,
  "svelteBracketNewLine": true,
  "svelteAllowShorthand": true
}' >>  .prettierrc.json

 printStars "Starting up  your editor & app"
    code -n  $projectDir/Svelte/$1/
    npm run dev
}

new_svelte_app() {
    cd $projectDir && [ -d $projectDir/Svelte ] || mkdir $projectDir/Svelte;
    printStars "Creating a Svelte default template";
    
    printf "$i Enter the name of the project: $r"; read projectName; printf $nf;
    
    printf "$q Choose your prefered module bundler: $nf \n$l $nf $o 1. Rollup \n$l $nf $o 2. Parcel \n"
    printf "$i Enter the number corresponding to your option: $r"; read bundleNo; printf $nf;
    #Rollup
    if [ $bundleNo = 1 ];  then
        printStars "Downloading the Svelte Template"
        svelte_with_rollup $projectName;
        #Parcel
        elif [ $bundleNo = 2 ]; then
        printStars "Setting up your Svelte Project with Parcel"
        svelte_with_parcel $projectName;
    fi;
}

export -f new_svelte_app

printStars  "Creating your HelloWorld Project just got easy"
printf "$q Which project do you want to create: $nf
$l $nf    *** Web Projects ***
$l $nf          |-- 1. Vue CLI template
$l $nf          |-- 2. Svelte default template
$l $nf          |-- 3. NodeJs basic template
$l $nf    *** Mobile Projects ***
$l $nf          |-- 4. Blank Flutter template \n"
printf "$i Enter the number corresponding to your option: $r"; read projectNo; printf $nf;
if [ $projectNo = 1 ]
then echo "Good, I like Apples";
elif [ $projectNo = 2 ]
then    new_svelte_app;
elif [ $projectNo = 3 ]
then echo "Good, I like Bananas";
else echo "Oh no, I hate Oranges!";
fi;


