BalsamiqXmlReader
=================
BalsamiqXmlReader is a GUI parser and creator for the Cocos2D-iPhone Engine.  

Every controls manage by [Balsamiq Mockup][1], which is the fast UI design software.

BalsamiqXmlReader parse *.bmml file, and create controls such as CCLabelTTF, CCSprite, CCMenuItemButton, UITextField etc... 

Requirements
====================

  * Cocos2d 1.0 or newer

Support controls
====================

   * CCLabelTTF
   * CCSprite
   * CCMenuItemButton
     * Subclass by CCMenuItemSprite, support button caption
   * CCProgressTimer
   * CCMenuItemToggle
   * CCLabelWithTextField
     * Subclass by CCLabelTTF, UITextField wrap
   * CCAlertLayer
   * CCBalsamiqLayer
   * CCSprite+LoadingBar
   * CCTableLayer
   * RadioManager

How to use BalsamiqXmlReader
===================== 

copy files at lib/BalsamiqXmlReader/ folder to your project

[1]: http://www.balsamiq.com/ "Balsamiq Mockup"