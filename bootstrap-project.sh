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
    if [  $choice != "No"  ] ||  [ $choice != "nO"  ] || [ $choice != "n" ]  ||  [ $choice != "NO"   ]; then
        printf "$q Where do you want to deploy your project: $nf \n$m 1. Heroku \n$m 2. Qovery \n$m 3. Now\n$m 4. Surge \n"
        printf "$i Enter the number corresponding to your option: $r"; read $deployTo; printf $nf;
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
    printStars "Starting up  your editor & app"
    npm install
    npm run build;
    deployProject;
    code -n  $projectDir/Svelte/$1;
    npm run dev;
}


# Creates a new Svelte Project with Parcel
svelte_with_parcel(){ # $1 is the projectName
    npx degit iljoo/svelte-tailwind-parcel-starter $1
    cd $1
    printStars "Install required packages"
    yarn
    printStars "Starting up  your editor & app"
    yarn start;
    yarn build;
    deployProject;
    code -n  $projectDir/Svelte/$1;
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

createFile(){
    touch package.json && printf '{
  "name": "svelte-app",
  "version": "1.0.0",
  "scripts": {
    "build": "rollup -c",
    "dev": "rollup -c -w",
    "start": "sirv public"
  },
  "devDependencies": {
    "@rollup/plugin-commonjs": "^11.0.0",
    "@rollup/plugin-node-resolve": "^7.0.0",
    "rollup": "^1.20.0",
    "rollup-plugin-livereload": "^1.0.0",
    "rollup-plugin-svelte": "^5.0.3",
    "rollup-plugin-terser": "^5.1.2",
    "svelte": "^3.0.0"
  },
  "dependencies": {
    "sirv-cli": "^0.4.4"
  }
}
    '>> package.json
}

editFile(){
    cd $projectDir && [ -d $projectDir/Svelte ] || mkdir $projectDir/Svelte;
    cd $projectDir/Svelte
    createFile;
    
    sed -i 's_"build": "rollup -c",_"build": "npm run build:tailwind \&\& rollup -c",_gI' package.json
    sed -i 's_"dev": "rollup -c -w",_"dev": "run-p start:dev autobuild watch:build",_gI' package.json 
    sed -i '/"start": "sirv public"/a\
    ,"watch:tailwind": "postcss public\/tailwind.css -o public\/index.css -w",\
    "build:tailwind": "NODE_ENV=production postcss public\/tailwind.css -o public\/index.css"' package.json;
    loopApp
}

loopApp(){
    printStars  "Creating your HelloWorld Project just got easy"
    printf "$q Which project do you want to create: $nf
$l $nf    *** Web Projects *** \n$m 1. Vue CLI template \n$m 2. Svelte default template \n$m 3. NodeJs basic template
    $l $nf    *** Mobile Projects *** \n$m 4. Blank Flutter template \n"
    printf "$i Enter the number corresponding to your option: $r"; read projectNo; printf $nf;
    if [ $projectNo = 1 ]
    then editFile;
    elif [ $projectNo = 2 ]
    then    new_svelte_app;
    elif [ $projectNo = 3 ]
    then createFile;
    else echo "Oh no, I hate Oranges!";
    fi;
}

printStars  "Creating your HelloWorld Project just got easy"
printf "$q Which project do you want to create: $nf
$l $nf    *** Web Projects *** \n$m 1. Vue CLI template \n$m 2. Svelte default template \n$m 3. NodeJs basic template
$l $nf    *** Mobile Projects *** \n$m 4. Blank Flutter template \n"
printf "$i Enter the number corresponding to your option: $r"; read projectNo; printf $nf;
if [ $projectNo = 1 ]
then editFile;
elif [ $projectNo = 2 ]
then    new_svelte_app;
elif [ $projectNo = 3 ]
then createFile;
else echo "Oh no, I hate Oranges!";
fi;

export -f new_svelte_app;