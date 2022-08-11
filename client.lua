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
	local CurrentJobGrade = ESX.PlayerData.job.grade_name

	for k, v in pairs(Config.BossRank) do
		if CurrentJobGrade == v then
			TriggerServerEvent('koe_jobsystem:GetAllJobs', CurrentJobName, CurrentJobGradeLabel) 
			break
		end
	end

end)

RegisterNetEvent('koe_jobsystem:openMenu')
AddEventHandler('koe_jobsystem:openMenu', function(jobs)
	local CurrentJobLabel = ESX.PlayerData.job.label

	local options = {
		{
			title = 'Current Job: '..CurrentJobLabel,
			icon = 'fas fa-briefcase'
		},
		{
			title = 'Clock Out',
			arrow = true,
			icon = 'fas fa-clock',
			event = 'koe_jobsystem:clockIn',
			args = {
				job = 'unemployed',
				grade = 0
			}
		},
	}

	if next(jobs) ~= nil then
		for k, v in pairs(jobs) do
			table.insert(options, 
				{
					title = v.job_label,
					description = 'Rank: '..v.rank_label,
					event = 'koe_jobsystem:remove',
					metadata = {'Click for more options.'},
					args = {
						job = v.job,
						grade = v.grade,
						rank_label = v.rank_label,
						job_label = v.job_label
					}
				}
			)	

		end
	else
		table.insert(options, 
				{
					title = 'Unemployed',
					description = 'Go out there and get work!'
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
				icon = 'fas fa-clock',
				args = {
					job = data.job,
					grade = data.grade,
					job_label = data.job_label,
					grade_label = data.rank_label,
				}
			},
			{
				title = 'Quit Job',
				icon = 'fas fa-person-running',
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
				title = 'Finances',
				arrow = true,
				event = 'koe_jobsystem:getFunds',
				icon = 'fas fa-money-bill-1',
				args = {
					employees = employees,
					CurrentJobName = CurrentJobName
				}
			},
			{
				title = 'Employees',
				arrow = true,
				event = 'koe_jobsystem:openEmployeeMenu',
				icon = 'fas fa-person',
				args = {
					employees = employees,
					CurrentJobName = CurrentJobName
				}
			},
		},
	})
	lib.showContext('bossmenu')

end)

RegisterNetEvent('koe_jobsystem:openEmployeeMenu')
AddEventHandler('koe_jobsystem:openEmployeeMenu', function(data)
	local employees = data.employees
	local employeesJob = data.CurrentJobName
	
	local options2 = {{title = 'Hire', description = 'Hire a new employee', arrow = true, event = 'koe_jobsystem:hireEmployee', icon = 'fas fa-handshake-simple', args = {jobtoHire = employeesJob}}, {title = 'Current Employees',icon = 'fas fa-angle-down'}}
	
	for k, v in pairs(employees) do

		table.insert(options2, 
			{
				title = v.firstname..' '..v.lastname,
				description = 'Rank: '..v.joblabel,
				metadata = {'Click for more options.'},
				event = 'koe_jobsystem:manageEmployee',
				args = {
					identifier = v.identifier,
					employeesJob = employeesJob
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


RegisterNetEvent('koe_jobsystem:manageEmployee')
AddEventHandler('koe_jobsystem:manageEmployee', function(data)
	identifier = data.identifier
	employeesJob = data.employeesJob


	lib.registerContext({
		id = 'manageemployee',
		title = 'Manage Employee',
		menu = 'employeemenu',
		options = {
			{
				title = 'Set Rank',
				description = 'Manage Rank',
				arrow = true,
				icon = 'fas fa-arrow-down-up-across-line',
				event = 'koe_jobsystem:rankManage',
				args = {
					identifier = identifier,
					employeesJob = employeesJob
				}
			},
			{
				title = 'Fire Employee',
				description = 'Remove employee from business',
				icon = 'fas fa-circle-xmark',
				arrow = true,
				event = 'koe_jobsystem:fireEmployee',
				args = {
					identifier = identifier,
					employeesJob = employeesJob
				}
			},
		},
	})
	
	lib.showContext('manageemployee')
	
end)

RegisterNetEvent('koe_jobsystem:rankManage')
AddEventHandler('koe_jobsystem:rankManage', function(data)
	local jobName = data.employeesJob
	local target = data.identifier

	TriggerServerEvent('koe_jobsystem:getRanksForJob', target, jobName)
end)


RegisterNetEvent('koe_jobsystem:promoteDemoteMenu')
AddEventHandler('koe_jobsystem:promoteDemoteMenu', function(jobGrades, jobName, target)

	local options3 = {}

	for k, v in ipairs(jobGrades) do
		
		table.insert(options3, 
			{
				title = v.label,
				event = 'koe_jobsystem:setNewRank',
				args = {
					rankLabel = v.label,
					jobName = jobName,
					target = target
				}
			}
			
		)
		
	end
	lib.registerContext({
		id = 'promotedemotemenu',
		title = 'Set Rank',
		menu = 'manageemployee',
		options = options3,
	})
	
	lib.showContext('promotedemotemenu')
	

end)

RegisterNetEvent('koe_jobsystem:setNewRank')
AddEventHandler('koe_jobsystem:setNewRank', function(data)
	local newRank = data.rankLabel
	local jobName = data.jobName
	local target = data.target
	TriggerServerEvent('koe_jobsystem:setRank', newRank, jobName, target)
end)

RegisterNetEvent('koe_jobsystem:hireEmployee')
AddEventHandler('koe_jobsystem:hireEmployee', function(data)
	local enterID = lib.inputDialog('Enter ID of the person', {'ID'})
	local jobtoHire = data.jobtoHire

	if enterID then
		local enteredID = tonumber(enterID[1])

		TriggerServerEvent('koe_jobsystem:hireEmployeeServer', enteredID, jobtoHire) 
	end
end)

RegisterNetEvent('koe_jobsystem:fireEmployee')
AddEventHandler('koe_jobsystem:fireEmployee', function(data)
	iden = data.identifier
	jobtoFire = data.employeesJob
	
	TriggerServerEvent('koe_jobsystem:fireEmployeeServer', iden, jobtoFire)
end)


RegisterNetEvent('koe_jobsystem:getFunds')
AddEventHandler('koe_jobsystem:getFunds', function(data)
	local currentJobSelected = data.CurrentJobName
	
	TriggerServerEvent('koe_jobsystem:getBusinessFunds', currentJobSelected)
end)

RegisterNetEvent('koe_jobsystem:openBusinessMenu')
AddEventHandler('koe_jobsystem:openBusinessMenu', function(accountBalance, society)
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
					currentBalance = currentBalance,
					society = society
				}
			},
			{
				title = 'Remove Funds:',
				description = 'Withdrawal Money',
				icon = 'fas fa-minus',
				arrow = true,
				event = 'koe_jobsystem:removeFunds',
				args = {
					currentBalance = currentBalance, 
					society = society
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
	local society = data.society

	TriggerEvent('koe_jobsystem:addFundsKeyboard', currentBalance, society)
end)

RegisterNetEvent('koe_jobsystem:removeFunds')
AddEventHandler('koe_jobsystem:removeFunds', function(data)
	local currentBalance = data.currentBalance
	local society = data.society

	TriggerEvent('koe_jobsystem:removeFundsKeyboard', currentBalance, society)
end)

RegisterNetEvent('koe_jobsystem:addFundsKeyboard')
AddEventHandler('koe_jobsystem:addFundsKeyboard', function(currentBalance, society)
	local input = lib.inputDialog('Enter Amount', {'Enter Amount'})

	if input then
		local enteredAmount = tonumber(input[1])
		local amountToAdd = currentBalance + enteredAmount

		TriggerServerEvent('koe_jobsystem:addBusinessFunds', amountToAdd, enteredAmount, society)
	end
end)

RegisterNetEvent('koe_jobsystem:removeFundsKeyboard')
AddEventHandler('koe_jobsystem:removeFundsKeyboard', function(currentBalance, society)
	local input2 = lib.inputDialog('Enter Amount', {'Enter Amount'})
 
	if input2 then
		local enteredAmount2 = tonumber(input2[1])

		TriggerServerEvent('koe_jobsystem:RemoveBusinessFunds', enteredAmount2, society)
	end
end)







