# Framework for Powershell Remote Execution using Powershell and SQL Server

This is the **Framework for Remote Execution using Powershell and SQL Server**. Or in short: **FREPS**

It is a data-driven solution for remotely controlling machines using Powershell.

Here's how this works:

1. You take your Powershell script, and shove its contents into a table at this central SQL Server instance.
2. You install one special Powershell script at each of the remote machines. It is a very lean script. All it does is connect to the central SQL Server instance and basically ask: What do I need to execute now? And whatever it is - execute it.
3. Set up a Scheduled Task to run this special script periodically on each of the machines.
4. You only need to set this up once on each of the remote machines and then you never need to manually touch them ever again.
5. Well, that's it, actually. It's super simple and elegant, and yet - extremely powerful!

# This is a Work-In-Progress

This repository is still unfinished.

Watch this repository to get notified about updates!
