 #!/bil escan/bash 
    
 projectDir='/home/parables/Workspace';  
 q='\e[96m|-- ? ';
 l='\e[96m|';
 i='\e[96m|-- < ';
 r='\e[34m';
 nf='\e[0m';
 
 # Prints out a Star bordered text    
printStars(){
printf "\e[95m\n****************************************************\n"
printf   "** \e[1m$1 **\n"
printf "****************************************************\e[0m\n" 
}
  
  # Creates a new Svelte Project with Parcel
new_svelte_app() {
cd $projectDir && mkdir $projectDir/Svelte;
printStars "Creating a Svelte default template"

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
        then 
 new_svelte_app;                
elif [ $projectNo = 3 ]
        then echo "Good, I like Bananas"
        else echo "Oh no, I hate Oranges!"
fi;


