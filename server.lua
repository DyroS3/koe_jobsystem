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

                        TriggerClientEvent('koe_jobsystem:openMenu',src, jobs)
                    end
                end)

            end)

        end

    end)

end)

RegisterNetEvent('koe_jobsystem:GetAllJobs')
AddEventHandler('koe_jobsystem:GetAllJobs', function(CurrentJobName, CurrentJobGradeLabel)
    local src = source
    local identifier =  ESX.GetPlayerFromId(source).identifier
    local employees = {}
    local employeeLabel = nil

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

            TriggerClientEvent('koe_jobsystem:openBusinessMenu', src, accountBalance)
        end
    end)

end)

RegisterNetEvent('koe_jobsystem:RemoveJob')
AddEventHandler('koe_jobsystem:RemoveJob', function(selectedJob)

    MySQL.query('DELETE FROM koe_jobsystem WHERE job = ? ', {selectedJob}, function()
    end)

end)

RegisterNetEvent('koe_jobsystem:SetJob')
AddEventHandler('koe_jobsystem:SetJob', function(jobToSet, gradeToSet)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    xPlayer.setJob(jobToSet, gradeToSet)
end)


