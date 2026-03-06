
{ flake, ... }:
{
  flake.homeModules.eza=
   {...} : let 
   shellAliases = {
    ls = "eza --icons";
   };
   
   in {
     programs.eza = {
        enable = true;
     };

     programs.bash = {
        inherit 
     };
   }



}