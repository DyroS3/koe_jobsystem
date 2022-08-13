
-- ░█████╗░██████╗░███████╗░█████╗░████████╗███████╗██████╗░  ██████╗░██╗░░░██╗  ██╗░░██╗░█████╗░███████╗
-- ██╔══██╗██╔══██╗██╔════╝██╔══██╗╚══██╔══╝██╔════╝██╔══██╗  ██╔══██╗╚██╗░██╔╝  ██║░██╔╝██╔══██╗██╔════╝
-- ██║░░╚═╝██████╔╝█████╗░░███████║░░░██║░░░█████╗░░██║░░██║  ██████╦╝░╚████╔╝░  █████═╝░██║░░██║█████╗░░
-- ██║░░██╗██╔══██╗██╔══╝░░██╔══██║░░░██║░░░██╔══╝░░██║░░██║  ██╔══██╗░░╚██╔╝░░  ██╔═██╗░██║░░██║██╔══╝░░
-- ╚█████╔╝██║░░██║███████╗██║░░██║░░░██║░░░███████╗██████╔╝  ██████╦╝░░░██║░░░  ██║░╚██╗╚█████╔╝███████╗
-- ░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝░░░╚═╝░░░╚══════╝╚═════╝░  ╚═════╝░░░░╚═╝░░░  ╚═╝░░╚═╝░╚════╝░╚══════╝

-- ░██████╗░█████╗░██████╗░██╗██████╗░████████╗░██████╗
-- ██╔════╝██╔══██╗██╔══██╗██║██╔══██╗╚══██╔══╝██╔════╝
-- ╚█████╗░██║░░╚═╝██████╔╝██║██████╔╝░░░██║░░░╚█████╗░
-- ░╚═══██╗██║░░██╗██╔══██╗██║██╔═══╝░░░░██║░░░░╚═══██╗
-- ██████╔╝╚█████╔╝██║░░██║██║██║░░░░░░░░██║░░░██████╔╝
-- ╚═════╝░░╚════╝░╚═╝░░╚═╝╚═╝╚═╝░░░░░░░░╚═╝░░░╚═════╝░

Config = {}

Config.MaxJobs = 2
Config.Unemployed = 'unemployed'
Config.UnemployedGrade = 0

Config.BossRank = {"boss", "deputy_sheriff", "deputy_chief", "co_director", "secretary", "captain", "sheriff"}







------------------------------------------------------------------------------
--------REPLACE BELOW IN es_extended server > classes > player.lua------------
------------------------------------------------------------------------------
-- function self.setJob(job, grade)
--     grade = tostring(grade)
--     local lastJob = json.decode(json.encode(self.job))

--     if ESX.DoesJobExist(job, grade) then
--         local jobObject, gradeObject = ESX.Jobs[job], ESX.Jobs[job].grades[grade]

--         self.job.id    = jobObject.id
--         self.job.name  = jobObject.name
--         self.job.label = jobObject.label

--         self.job.grade        = tonumber(grade)
--         self.job.grade_name   = gradeObject.name
--         self.job.grade_label  = gradeObject.label
--         self.job.grade_salary = gradeObject.salary

--         if gradeObject.skin_male then
--             self.job.skin_male = json.decode(gradeObject.skin_male)
--         else
--             self.job.skin_male = {}
--         end

--         if gradeObject.skin_female then
--             self.job.skin_female = json.decode(gradeObject.skin_female)
--         else
--             self.job.skin_female = {}
--         end

--         TriggerEvent('esx:setJob', self.source, self.job, lastJob)
--         self.triggerEvent('esx:setJob', self.job)

--         exports['koe_jobsystem']:addjob(self.identifier, self.job.name, self.job.grade)
--     else
--         print(('[es_extended] [^3WARNING^7] Ignoring invalid .setJob() usage for "%s"'):format(self.identifier))
--     end
-- end