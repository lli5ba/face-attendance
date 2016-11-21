parallel = parallel:cuda()
clusterSize = 0
correct = 0
avgDist = 0

imgSize = 120

--batch size 10
local rand_num1 = 2 --number between 1 and trainBatches
local rand_num2 = 5 --number between 1 and 10
local randbatch = data.getBatch(rand_num1, 'train')
local test_img = randbatch[1][rand_num2] --can change rand_num2 and 1 to find good anchor

--get the test_img embedding
local resize_inputs = {torch.Tensor(batchSize, 3, imgSize, imgSize),
	torch.Tensor(batchSize, 3, imgSize, imgSize),
	torch.Tensor(batchSize, 3, imgSize, imgSize)}

for apn = 1, 3 do
	for imgN = 1, batchSize do
		resize_inputs[apn][imgN] = image.scale(inputs[apn][imgN], imgSize, imgSize)
	end
end
--print('pass')
aImgs = resize_inputs[1]
-- Positive training samples/images
pImgs = resize_inputs[2]
-- Negative training samples/images
nImgs = resize_inputs[3]

local inputs = {aImgs, pImgs, nImgs}
predict = parallel:forward({aImgs:cuda(), pImgs:cuda(), nImgs:cuda()})

local test_img_emb = predict[1][rand_num2]

function print_scaled_image(img)
	itorch.image(image.scale(img, 48, 48))
end

--threshold from panda histogram
local threshold = 0.6475

local file = io.open("clusterdist_" .. tostring(rand_num1) .. "_" .. tostring(rand_num2) .. ".txt", "a")
for i = 1, trainBatches do
        --print(i .. " " .. trainBatches)
        local inputs = data.getBatch(i, 'train')
        local resize_inputs = {torch.Tensor(batchSize, 3, imgSize, imgSize),
            torch.Tensor(batchSize, 3, imgSize, imgSize),
            torch.Tensor(batchSize, 3, imgSize, imgSize)}

        for apn = 1, 3 do
            for imgN = 1, batchSize do
                resize_inputs[apn][imgN] = image.scale(inputs[apn][imgN], imgSize, imgSize)
            end
        end
        --print('pass')
        aImgs = resize_inputs[1]
        -- Positive training samples/images
        pImgs = resize_inputs[2]
        -- Negative training samples/images
        nImgs = resize_inputs[3]
        
        local inputs = {aImgs, pImgs, nImgs}
        predict = parallel:forward({aImgs:cuda(), pImgs:cuda(), nImgs:cuda()})
       
        for batchN = 1, batchSize do
            local anchor_test = computeSimilarity(predict[1][batchN], test_img_emb)
            if (anchor_test <= threshold) then
                clusterSize = clusterSize + 1
				avgDist = avgDist + anchor_test
				file:write(('%.6f\n'):format(anchor_test))
                printImage(inputs[1][batchN])
				file:flush()
            end
           
        end

end

avgDist = avgDist/clusterSize
print("Total clusterSize: " .. clusterSize)
print("Average distance for similar images: " .. avgDist)

file:write("\nITotal clusterSize" .. clusterSize)
file:write("\nAverage distance for similar images: " .. avgDist)

file:close()