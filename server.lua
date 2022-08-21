----Gets ESX-----
ESX = nil
local ox_inventory = exports.ox_inventory
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
----------------------------------------------------------------

RegisterNetEvent('koe_jobsystem:GetJobs')
AddEventHandler('koe_jobsystem:GetJobs', function()
    local src = source
    local identifier =  ESX.GetPlayerFromId(source).identifier
    local jobs = {}

    MySQL.query('SELECT * FROM koe_jobsystem WHERE identifier = ?', {identifier}, function(result)
        
        if next(result) ~= nil then
           
            for k, v in ipairs(result) do

                MySQL.prepare('SELECT label FROM jobs WHERE name = ?', {v.job}, function(result2)

                    MySQL.query('SELECT label FROM job_grades WHERE job_name = @job AND grade = @grade',{ ['@job'] = v.job, ['@grade'] = v.grade }, function(result3)

                        for k1, v2 in ipairs(result3) do
                            table.insert(jobs, 
                                {
                                    job = v.job,
                                    grade = v.grade,
                                    identifier = v.identifier,
                                    job_label = result2,
                                    rank_label = v2.label
                                }
                            )

                            TriggerClientEvent('koe_jobsystem:openMenu',src, jobs, identifier)
                        end
                    end)

                end)

            end
        else
            TriggerClientEvent('koe_jobsystem:openMenu',src, jobs)
        end

    end)

end)

RegisterNetEvent('koe_jobsystem:GetAllJobs')
AddEventHandler('koe_jobsystem:GetAllJobs', function(CurrentJobName, CurrentJobGradeLabel)
    local src = source
    local identifier =  ESX.GetPlayerFromId(source).identifier
    local employees = {}

    MySQL.query('SELECT * FROM koe_jobsystem where job = ?', {CurrentJobName}, function(allresult)

        for k, v in pairs(allresult) do

            MySQL.query('SELECT label FROM job_grades WHERE job_name = @job AND grade = @grade',{ ['@job'] = v.job, ['@grade'] = v.grade }, function(allresult2)
                

                MySQL.query('SELECT firstname, lastname FROM users where identifier = ?', {v.identifier}, function(allresult3)

                    for k2, v2 in pairs(allresult3) do

                        for k3, v3 in pairs(allresult2) do
                            table.insert(employees, 
                                {
                                    firstname = v2.firstname,
                                    lastname = v2.lastname,
                                    identifier = v.identifier,
                                    joblabel = v3.label,
            
                                }
                            )

                        TriggerClientEvent('koe_jobsystem:openBossMenu',src, employees, CurrentJobName)
                        end
                    end
                end)
            end)
        end
    end)

end)

RegisterNetEvent('koe_jobsystem:getBusinessFunds')
AddEventHandler('koe_jobsystem:getBusinessFunds', function(CurrentJobName, CurrentJobGradeLabel)
    local src = source
    local society = 'society_'..CurrentJobName

    MySQL.query('SELECT money FROM addon_account_data where account_name = ?', {society}, function(funds)
        for k, v in pairs(funds) do
            local accountBalance = v.money

            TriggerClientEvent('koe_jobsystem:openBusinessMenu', src, accountBalance, society)
        end
    end)

end)

RegisterNetEvent('koe_jobsystem:RemoveJob')
AddEventHandler('koe_jobsystem:RemoveJob', function(selectedJob, identifier, grade)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.query('DELETE FROM koe_jobsystem WHERE identifier = @identifier AND job = @job AND grade = @grade',{ ['@identifier'] = identifier, ['@job'] = selectedJob, ['@grade'] = grade }, function()

    end)
    
    xPlayer.setJob(Config.Unemployed, Config.UnemployedGrade)
end)

RegisterNetEvent('koe_jobsystem:SetJob')
AddEventHandler('koe_jobsystem:SetJob', function(jobToSet, gradeToSet)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    xPlayer.setJob(jobToSet, gradeToSet)
end)

function addjob(identifier, job, grade)
    local count = 0
    local hasjob = false

    MySQL.Async.fetchAll("SELECT * FROM koe_jobsystem WHERE identifier = @identifier",
    {
        ["@identifier"] = identifier
    },
    function(resultjob)


        for k, v in ipairs(resultjob) do
            count = count + 1
        end

        local getjob = exports.oxmysql:scalar_async('SELECT job FROM koe_jobsystem WHERE identifier = @identifier AND job = @job', {
            ['@identifier'] = identifier,
            ['@job'] = job
        })

        if getjob then hasjob = true end

        if count < Config.MaxJobs and hasjob == false then
            if job ~= 'unemployed' then
                MySQL.Sync.execute("INSERT INTO `koe_jobsystem`(`identifier`, `job`, `grade`) VALUES (@identifier, @job, @grade)",
                    {["@identifier"] = identifier, ["@job"] = job, ["@grade"] = grade}
                ) 
            end
        end

    end)
end

function removejob(identifier, job, grade)

    MySQL.query('DELETE FROM koe_jobsystem WHERE identifier = @identifier AND job = @job AND grade = @grade',{ ['@identifier'] = identifier, ['@job'] = job, ['@grade'] = grade }, function()

    end)
end

function getjobs(identifier)

    MySQL.query('SELECT * FROM koe_jobsystem WHERE identifier = ?', {identifier}, function(jobs)

    end)
    
end

RegisterNetEvent('koe_jobsystem:addBusinessFunds')
AddEventHandler('koe_jobsystem:addBusinessFunds', function(amountToAdd, enteredAmount, society)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
 
    if xPlayer.getMoney() >= enteredAmount then

        TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
            if account then
                account.addMoney(enteredAmount)
                xPlayer.removeMoney(enteredAmount)
            end
        end)
        TriggerClientEvent('ox_lib:notify', src, {type = 'inform', description = "You deposited "..enteredAmount..' new account balance is $'..amountToAdd, duration = 8000, position = 'top'})
    else
        TriggerClientEvent('ox_lib:notify', src, {type = 'error', description = "Not enough money", duration = 8000, position = 'top'})
    end

end)

RegisterNetEvent('koe_jobsystem:RemoveBusinessFunds')
AddEventHandler('koe_jobsystem:RemoveBusinessFunds', function(enteredAmount2, society)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
        if account then
            account.removeMoney(enteredAmount2)
            xPlayer.addMoney(enteredAmount2)
        end
    end)

end)

RegisterNetEvent('koe_jobsystem:hireEmployeeServer')
AddEventHandler('koe_jobsystem:hireEmployeeServer', function(enteredID, jobtoHire)
    local target = ESX.GetPlayerFromId(enteredID) 

    if target.identifier ~= nil then
        target.setJob(jobtoHire, 0)
    end  
end)

RegisterNetEvent('koe_jobsystem:fireEmployeeServer')
AddEventHandler('koe_jobsystem:fireEmployeeServer', function(iden, jobtoFire)
    local src = source
    local xPlayer = ESX.GetPlayerFromIdentifier(iden)
    local unemployed = Config.Unemployed
    local grade = Config.UnemployedGrade

    MySQL.query('DELETE FROM koe_jobsystem WHERE identifier = @identifier AND job = @job',{ ['@identifier'] = iden, ['@job'] = jobtoFire }, function()

    end)

    if xPlayer ~= nil then
        xPlayer.setJob(unemployed, grade)
    end

end)

RegisterNetEvent('koe_jobsystem:getRanksForJob')
AddEventHandler('koe_jobsystem:getRanksForJob', function(target, jobName)
    local src = source
    local jobGrades = {}
    MySQL.query('SELECT label FROM job_grades WHERE job_name = @job',{ ['@job'] = jobName}, function(jobRanks)

        for k, v in ipairs(jobRanks) do
            
            table.insert(jobGrades, v)
            
        end
        table.sort(jobGrades, function(a,b) return a.label < b.label end)

        TriggerClientEvent('koe_jobsystem:promoteDemoteMenu',src,  jobGrades, jobName, target)
    end)
end)

RegisterNetEvent('koe_jobsystem:setRank')
AddEventHandler('koe_jobsystem:setRank', function(newRank, jobName, target)
    local src = source
    local xPlayer = ESX.GetPlayerFromIdentifier(target)

    MySQL.query('DELETE FROM koe_jobsystem WHERE identifier = @identifier AND job = @job',{ ['@identifier'] = target, ['@job'] = jobName }, function()

    end)

    local newGrade = exports.oxmysql:scalar_async('SELECT grade FROM job_grades WHERE label = @newRank', {
        ['@newRank'] = newRank
    })

    xPlayer.setJob(jobName, newGrade)
end)


RegisterNetEvent('koe_kobsystem:getSalaries')
AddEventHandler('koe_kobsystem:getSalaries', function(jobToGetSalaries)
    local src = source

    local Salaries = {}
    MySQL.query('SELECT * FROM job_grades WHERE job_name = @job',{ ['@job'] = jobToGetSalaries}, function(jobSalaries)

        for k, v in pairs(jobSalaries) do

            table.insert(Salaries, v)
            
        end

        TriggerClientEvent('koe_jobsystem:salaryMenu',src,  Salaries)
    end)

end)

RegisterNetEvent('koe_jobsystem:setNewSalary')
AddEventHandler('koe_jobsystem:setNewSalary', function(enteredSalary, jobToChangeSalary)

    MySQL.query('UPDATE job_grades SET salary = @salary WHERE label = @label',{ ['@salary'] = enteredSalary, ['@label'] = jobToChangeSalary}, function()

    end)

end)