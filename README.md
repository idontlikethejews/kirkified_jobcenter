# kirkified_jobcenter

## Fully secured and optimized jobcenter script for FiveM

A modern job center system for ESX-based FiveM servers. Built with performance and security in mind.

## 🛠️ Technology Stack

- **Backend**: Lua (server-side & client-side)
- **Frontend**: React with Tailwind CSS
- **Icons**: Iconify
- **Framework**: ESX Legacy
- **Target System**: ox_target
- **UI Library**: ox_lib

## ✨ Features

### Security & Performance
- Server-side validation for all job applications (instead of using parsing the job name by e.g. TriggerServerEvent("jobcenter", "police") we just enforced usage of job index numbers)
- Anti-spam protection with cooldown timers (safer for your serverside as it cant be over-spammed)
- Distance verification to prevent additional possible exploits

### Job Management
- Check if player is already employed in the same job
- Grade comparison - prevents downgrading from higher positions
- Dynamic salary loading from database
- Customizable job requirements display
- Support for unlimited jobs

### User Interface
Three stunning UI styles to choose from:

1. **Minimalistic** - Clean and simple design focused on essential information
   ![minimal](https://i.ibb.co/TMHHG9Md/minimal.png)
2. **Cards** - Modern card-based layout with rich visuals
   ![cards](https://i.ibb.co/KcmHyJTb/cards.png)  
3. **Split** - Split-screen design with filters for detailed job browsing
   ![split](https://i.ibb.co/RpfD5tTx/split.png) 

### Interaction Methods (every through ox_target)
- NPC peds (configurable vec4 position and npc model)
- Sphere zones
- Model-based targeting for props (configurable vec3 position and prop model)

### Localization
- Multi-language support (English & Polish included)
- Easy to add custom languages via JSON files
- Locale files for all notifications

## 📦 Dependencies

- [es_extended](https://github.com/esx-framework/esx_legacy)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)
- [oxmysql](https://github.com/overextended/oxmysql)

## 📥 Installation

1. Download and extract the script to your resources folder
2. Add `ensure kirkified_jobcenter` to your server.cfg
3. Configure `config.lua` to your preferences
4. Add your jobs to the `Config.Jobs` table
5. Restart your server
