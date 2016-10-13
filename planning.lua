-- load images, scale, store in tensor


-- make labels


--Load the AlexNet model
alexnet = torch.load('alexnetowtbn_epoch55_cpu.t7')
alexnet:evaluate()

-- Pre-process the image channel by channel.
function preprocess(im)
    local output_image = image.scale(im:clone(), 224, 224)
    for i = 1, 3 do -- channels
        output_image[{{i},{},{}}]:add(-meanStd.mean[i])
        output_image[{{i},{},{}}]:div(meanStd.std[i])
    end
    return output_image
end

--Get fc6 output given a model and input image
function fc6output(model, im)
    
    

--Build linear model (takes 2(4096))
--run "linearmodel:forward({x, y})", x and y are fc6outputs
function build_linear_model():
    local linearmodel = nn.Sequential()
    linearmodel:add(nn.PairwiseDistance(2))
    linearmodel:add(nn.Linear(4096,512))
    linearmodel:add(nn.Linear(512, 1))
    return linearmodel

function predict(model, img_a, img_b):
    fc6_a = fc6output(alexnet, img_a)
    fc6_b = fc6output(alexnet, img_b)
    model:forward({fc6_b})
    
    
