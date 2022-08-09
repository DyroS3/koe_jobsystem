----Gets ESX-------------------------------------------------------------------------------------------------------------------------------
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end

	PlayerLoaded = true
	ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	PlayerLoaded = true
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

AddEventHandler('esx:onPlayerSpawn', function()
    local ped = PlayerPedId()
end)
---------------------------------------------------------------------------------------------------------------------------------------

RegisterCommand('jobs', function(source)
	TriggerServerEvent('koe_jobsystem:GetJobs')
end)	

RegisterCommand('bossmenu', function(source)
	local CurrentJobName = ESX.PlayerData.job.name
	local CurrentJobGradeLabel = ESX.PlayerData.job.grade_label

	TriggerServerEvent('koe_jobsystem:GetAllJobs', CurrentJobName, CurrentJobGradeLabel)

end)

RegisterNetEvent('koe_jobsystem:openMenu')
AddEventHandler('koe_jobsystem:openMenu', function(jobs)
	local CurrentJobLabel = ESX.PlayerData.job.label
		
	local options = {
		{
			title = 'Current Job: '..CurrentJobLabel
		},
		{
			title = 'Go off duty',
			arrow = true,
			event = 'koe_jobsystem:clockIn',
			args = {
				job = 'unemployed',
				grade = 0
			}
		},
	}

	for k, v in pairs(jobs) do
		print(v.label)
		table.insert(options, 
			{
				title = v.job_label,
				description = 'Rank: '..v.rank_label,
				event = 'koe_jobsystem:remove',
				args = {
					job = v.job,
					grade = v.grade,
					rank_label = v.rank_label,
					job_label = v.job_label
                }
			}
        )	

	end

	lib.registerContext({
		id = 'jobMainMenu',
		title = 'Job Menu',
		options = options,
	})
	
	lib.showContext('jobMainMenu')

end)

RegisterNetEvent('koe_jobsystem:remove')
AddEventHandler('koe_jobsystem:remove', function(data)

	lib.registerContext({
		id = 'removemenu',
		title = 'Job Management',
		menu = 'jobMainMenu',
		options = {
			{
				title = 'Clock In',
				arrow = true,
				event = 'koe_jobsystem:clockIn',
				args = {
					job = data.job,
					grade = data.grade,
					job_label = data.job_label,
					grade_label = data.rank_label,
				}
			},
			{
				title = 'Remove Job',
				menu = 'areyousure',
				arrow = true,
			},
		},
		{
			id = 'areyousure',
			title = 'Are You Sure?',
			menu = 'removemenu',
			options = {
				{
					title = 'Yes',
					event = 'koe_jobsystem:removeJob',
					args = {
						job = data.job
					}
				},
			}
		}
	})
	lib.showContext('removemenu')
end)


RegisterNetEvent('koe_jobsystem:removeJob')
AddEventHandler('koe_jobsystem:removeJob', function(data)
	local selectedJob = data.job

	lib.notify({
		title = 'Job Menu',
		description = 'Job has been removed',
		type = 'inform',
		duration = 8000,
		position = 'top'
	})

	TriggerServerEvent('koe_jobsystem:RemoveJob', selectedJob)
end)

RegisterNetEvent('koe_jobsystem:clockIn')
AddEventHandler('koe_jobsystem:clockIn', function(data)	
	local jobToSet = data.job
	local gradeToSet = data.grade

	if data.job == 'unemployed' then
		lib.notify({
			title = 'Job Menu',
			description = 'You are now unemployed',
			type = 'inform',
			duration = 8000,
			position = 'top'
		})
	else
		lib.notify({
			title = 'Job Menu',
			description = 'Clocked in as '..data.job_label..' Rank: '..data.grade_label,
			type = 'inform',
			duration = 8000,
			position = 'top'
		})
	end
	TriggerServerEvent('koe_jobsystem:SetJob', jobToSet, gradeToSet)
end)

RegisterNetEvent('koe_jobsystem:openBossMenu')
AddEventHandler('koe_jobsystem:openBossMenu', function(employees, CurrentJobName)
		
	lib.registerContext({
		id = 'bossmenu',
		title = 'Boss Menu',
		options = {
			{
				title = 'Business Management',
				arrow = true,
				event = 'koe_jobsystem:getFunds',
				args = {
					employees = employees,
					CurrentJobName = CurrentJobName
				}
			},
			{
				title = 'Employees',
				arrow = true,
				event = 'koe_jobsystem:openEmployeeMenu',
				args = {
					employees = employees
				}
			},
		},
	})
	lib.showContext('bossmenu')

end)

RegisterNetEvent('koe_jobsystem:openEmployeeMenu')
AddEventHandler('koe_jobsystem:openEmployeeMenu', function(data)
	local employees = data.employees

	local options2 = {{title = 'Hire', description = 'Hire a new employee', arrow = true}, {title = 'Current Employees',icon = 'fas fa-person'}}
	
	for k, v in pairs(employees) do

		table.insert(options2, 
			{
				title = v.firstname..' '..v.lastname,
				description = 'Rank: '..v.joblabel,
				args = {
					identifier = v.identifier
				}
			}
		)	
	
	end
	
	lib.registerContext({
		id = 'employeemenu',
		title = 'Employee Menu',
		menu = 'bossmenu',
		options = options2,
	})
	
	lib.showContext('employeemenu')
	

end)

RegisterNetEvent('koe_jobsystem:getFunds')
AddEventHandler('koe_jobsystem:getFunds', function(data)
	local currentJobSelected = data.CurrentJobName
	
	TriggerServerEvent('koe_jobsystem:getBusinessFunds', currentJobSelected)
end)

RegisterNetEvent('koe_jobsystem:openBusinessMenu')
AddEventHandler('koe_jobsystem:openBusinessMenu', function(accountBalance)
	currentBalance = accountBalance
	accountBalance = format_int(string.format("%.2f", accountBalance))

	lib.registerContext({
		id = 'businessmenu',
		title = 'Manage Business',
		menu = 'bossmenu',
		options = {
			{
				title = 'Account Balance:',
				description = '$'..accountBalance,
				icon = 'fas fa-money-bill'
			},
			{
				title = 'Add Funds:',
				description = 'Deposit Money',
				icon = 'fas fa-plus',
				arrow = true,
				event = 'koe_jobsystem:addFunds',
				args = {
					currentBalance = currentBalance
				}
			},
			{
				title = 'Remove Funds:',
				description = 'Withdrawal Money',
				icon = 'fas fa-minus',
				arrow = true,
				event = 'koe_jobsystem:removeFunds',
				args = {
					currentBalance = currentBalance
				}
			},
		},
	})
	
	lib.showContext('businessmenu')
	

end)

--Thank you brandond97
function format_int(number)

    local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
  
    -- reverse the int-string and append a comma to all blocks of 3 digits
    int = int:reverse():gsub("(%d%d%d)", "%1,")
  
    -- reverse the int-string back remove an optional comma and put the 
    -- optional minus and fractional part back
    return minus .. int:reverse():gsub("^,", "") .. fraction
end

RegisterNetEvent('koe_jobsystem:addFunds')
AddEventHandler('koe_jobsystem:addFunds', function(data)
	local currentBalance = data.currentBalance
	
	print(currentBalance)
end)

RegisterNetEvent('koe_jobsystem:removeFunds')
AddEventHandler('koe_jobsystem:removeFunds', function(data)
	local currentBalance = data.currentBalance
	
	print(currentBalance)
end)







