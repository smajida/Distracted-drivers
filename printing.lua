function show_figure(list_error_train,list_error_test,list_loss_train,list_loss_test)

	-- log results to files
	accLogger = optim.Logger('accuracy.log')
	LossLogger = optim.Logger('Loss.log')

	for i=1, #list_error_train do
	-- update logger
		accLogger:add{['% train accuracy'] = list_error_train[i], ['% test accuracy'] = 					list_error_test[i]}
		LossLogger:add{['% train loss']    = list_loss_train[i], ['% test loss']    = 					list_loss_test[i]}
	end
	-- plot logger
	accLogger:style{['% train accuracy'] = '-', ['% test accuracy'] = '-'}
	LossLogger:style{['% train loss']    = '-', ['% test loss']    = '-'}
	accLogger:plot()
	LossLogger:plot()
end

-- truth: integers between 1 and 10
function count_error(truth, prediction,class_Accuracy)
	local errors=0
	maxs, indices = torch.max(prediction,2)
	for i=1,truth:size(1) do
	    if truth[i] ~= indices[i][1] then
		--print(truth[i].." vs "..indices[i][1])
		errors = errors + 1
	    else
		--print(truth[i].." = "..indices[i][1])
		class_Accuracy[truth[i]] = class_Accuracy[truth[i]] + 1
	    end
	end
	return errors, class_Accuracy
end


function print_performance(im_list, Batchsize, net, criterion, classes, image_width, image_height,Type)
	local correct = 0
	local nbBatch=math.floor(#im_list.label/Batchsize)+1
	local class_Accuracy = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	local errors_tot=0
	local loss_tot=0

	print(nbBatch.. " Test Batchs ")
	for i=1, nbBatch do
	    local Data=getBatch(im_list, Batchsize, image_width, image_height, i-1, Type)
	    Data.data= Data.data:cuda()
	    Data.label= Data.label:cuda()
	    local groundtruth = Data.label
	    --image.display(Data.data)
	    local prediction = net:forward(Data.data)--one image per batch
	    local loss=criterion:forward(prediction, groundtruth)
	    loss_tot=loss_tot+loss
	    --!--local confidences, indices = torch.sort(prediction, true)  --true -> sort in descending order
	    errors, class_Accuracy=count_error(groundtruth, prediction,class_Accuracy)
	    errors_tot=errors_tot+errors
	end
	print("----------------"..Type.."-----------------")
	print('loss_tot '.. loss_tot/nbBatch) 
	print("nb errors : ".. errors_tot)
	print("errors : "..100*errors_tot/(nbBatch*Batchsize).. ' % ')
	--print("Classe Accuracy: ")
	--for i=1,#classes do
	--    print(classes[i], 100*class_Accuracy[i]/(nbBatch*Batchsize) .. ' %')
	--end
	print("-------------------------------------")

	return 100*errors_tot/(nbBatch*Batchsize), loss_tot/nbBatch
end
