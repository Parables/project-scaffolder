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
m='\e[96m| \e[0m           |-- ';

# Prints out a Star bordered text
printStars(){
    printf "\e[95m\n****************************************************\n"
    printf   "** \e[1m$1 **\n"
    printf "****************************************************\e[0m\n"
}


deploy_to_now(){
    npm install -g now
    cd public
    now
}

deploy_to_surge(){
    npm install -g surge
    npm run build
    surge public
}

deployProject(){
    printStars "Deploy Project"
    read -e -p "Do you want to deploy your project(Y/n)? :   " -i "Y" choice ;printf $nf;
    echo $choice;
    if [  $choice != "No"  ] ||  [ $choice != "nO"  ] || [ $choice != "n" ]  ||  [ $choice != "NO"   ]; then
        printf "$q Where do you want to deploy your project: $nf \n$m 1. Heroku \n$m 2. Qovery \n$m 3. Now\n$m 4. Surge \n"
        printf "$i Enter the number corresponding to your option: $r"; read deployTo; printf $nf;
        if [ $deployTo = 1 ]
        then printStars "Deploying to Heroku";
        elif [ $deployTo = 2 ]
        then   printStars "Deploying to Qovery";
        elif [ $deployTo = 3 ]
        then printStars "Deploying to Now";
            deploy_to_now;
        elif [ $deployTo = 3 ]
        then printStars "Deploying to Surge";
            deploy_to_surge
        else echo "Invalid option selected... ";
        fi;
    fi
}

allow_external_connetion(){
    #--host 0.0.0.0
    echo "done"
}

# Creates a new Svelte Project with Rollup (default)
svelte_with_rollup(){ # $1 is the projectName
    npx degit sveltejs/template $1
    cd $1
    
    printStars "Installing required packages"
    read -e -p "Do you want to add TailwindCss(Y/n)? :   "  choice ;printf $nf;
    if [  $choice != "No"  ] ||  [ $choice != "nO"  ] || [ $choice != "n" ]  ||  [ $choice != "NO"   ]; then
        printStars "Adding TailwindCss"
        npm install tailwindcss postcss-cli --save-dev
        npm install @fullhuman/postcss-purgecss
        ./node_modules/.bin/tailwind init tailwind.js
        npm install npm-run-all --save-dev
        touch postcss.config.js  && printf 'const tailwindcss = require("tailwindcss");

// only needed if you want to purge
const purgecss = require("@fullhuman/postcss-purgecss")({
  content: ["./src/**/*.svelte", "./public/**/*.html"],
  defaultExtractor: content => content.match(/[A-Za-z0-9-_:/]+/g) || []
});

module.exports = {
  plugins: [
    tailwindcss("./tailwind.js"),

    // only needed if you want to purge
    ...(process.env.NODE_ENV === "production" ? [purgecss] : [])
  ]
        };' >> postcss.config.js ;
        
        touch public/tailwind.css && printf '
        @tailwind base;
        @tailwind components;
        @tailwind utilities;' >> public/tailwind.css ;
        
        sed -i 's_"build": "rollup -c",_"build": "npm run build:tailwind \&\& rollup -c",_gI' package.json
        sed -i 's_"dev": "rollup -c -w",_"dev": "run-p start:dev autobuild --watch:build",_gI' package.json
        sed -i '/"start": "sirv public"/a\
    ,"watch:tailwind": "postcss public\/tailwind.css -o public\/index.css -w",\
        "build:tailwind": "NODE_ENV=production postcss public\/tailwind.css -o public\/index.css",\
        "start:dev": "sirv public --dev",\
        "autobuild": "rollup -c -w"' package.json;
        
        rm public/index.html;
        touch public/index.html && printf "<!doctype html>
<html>

<head>
	<meta charset='utf8'>
	<meta name='viewport' content='width=device-width'>

	<title>Svelte app</title>

	<link rel='icon' type='image/png' href='favicon.png'>
	<link rel='stylesheet' href='global.css'>
	<link rel='stylesheet' href='build/bundle.css'>
	<link rel='stylesheet' href='index.css'>
</head>

<body>
	<script src='build/bundle.js'></script>
</body>
        " >> public/index.html;
    fi
    
    printStars "Starting up  your editor & app"
    npm install
    npm run build;
    deployProject;
    code -n  $projectDir/Svelte/$1;
    npm run dev;
}


# Creates a new Svelte Project with Parcel
svelte_with_parcel(){ # $1 is the projectName
    npx degit Parables/svelte-tailwindcss-parcel-template $1
    cd $1
    printStars "Installing dependencies"
    npm install
    printStars "Starting up  your editor & app"
    code .
    deployProject;
    npm start;
    npm build;
}


new_svelte_app() {
    cd $projectDir && [ -d $projectDir/Svelte ] || mkdir $projectDir/Svelte;
    cd $projectDir/Svelte
    printStars "Creating  Svelte Starter template";
    printf "$i Enter the name of the project: $r"; read projectName; printf $nf;
    printf "$q Choose your prefered module bundler: $nf \n$l $nf $o 1. Rollup \n$l $nf $o 2. Parcel \n"
    printf "$i Enter the number corresponding to your option: $r"; read bundleNo; printf $nf;
    #Rollup
    if [ $bundleNo = 1 ];  then
        printStars "Setting up your Svelte Project with Rollup & TailwindCss"
        svelte_with_rollup $projectName;
        #Parcel
        elif [ $bundleNo = 2 ]; then
        printStars "Setting up your Svelte Project with Parcel & TailwindCss"
        svelte_with_parcel $projectName;
    fi;
}



# Script Entry point
printStars  "Creating your HelloWorld Project just got easy"
printf "$q Which project do you want to create: $nf
$l $nf    *** Web Projects *** \n$m 1. Vue CLI template \n$m 2. Svelte default template \n$m 3. NodeJs basic template
$l $nf    *** Mobile Projects *** \n$m 4. Blank Flutter template \n"
printf "$i Enter the number corresponding to your option: $r"; read projectNo; printf $nf;
if [ $projectNo = 1 ]
then echo "option 1";
elif [ $projectNo = 2 ]
then    new_svelte_app;
elif [ $projectNo = 3 ]
then echo "option 3"
else echo "Oh no, I hate Oranges!";
fi;

export -f new_svelte_app;