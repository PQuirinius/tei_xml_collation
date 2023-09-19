var sum
var x
window.onload = init;
var highList

function init () {
    
    list = document.querySelectorAll(".nombre");
        sum = 0;
        list.forEach(function (thisField) {sum += parseInt(thisField.innerHTML)});
        sum /= list.length;
        console.log(sum);
        list.forEach(function (thisField) {
            x=parseInt(thisField.innerHTML);
            switch (true) {            
            case (x===0):
                thisField.style.backgroundColor = "#f7d9aa";
                thisField.style.color = "#333333";
                break;
            case (x<sum/3):
                thisField.style.backgroundColor = "#f7d9aa";
                thisField.style.color = "#333333";
                break;
            
            case (x<sum*2): {thisField.style.backgroundColor = "#f3a87a"; thisField.style.color = "#ffffff"};
            break;
            default: {thisField.style.backgroundColor = "#ef7a51"; thisField.style.color = "#ffffff"}
        }
        })
        document.querySelectorAll(".sigles").forEach(function (thisField) {
            thisField.innerHTML = thisField.innerHTML.replaceAll('#', '').replaceAll(' ', ' ')
        })
        document.querySelector('#collBut').addEventListener('click', toCollation);
        document.querySelectorAll('.highBx').forEach(function (thisBox) {thisBox.addEventListener('change', highlight)});
        document.querySelectorAll('.lowBx').forEach(function (thisBox) {thisBox.addEventListener('change', highlight)});
        document.querySelector('#combCount').innerHTML = document.querySelectorAll('.sigles').length
        
        if(localStorage['highList'] != undefined) {tempHighList = JSON.parse(localStorage['highList']);
        document.querySelectorAll('.highBx').forEach(function (thisBx) {if(tempHighList.includes(thisBx.value)) {thisBx.checked = true}})
    };
        if(localStorage['lowList'] != undefined) {tempLowList = JSON.parse(localStorage['lowList']);
        document.querySelectorAll('.lowBx').forEach(function (thisBx) {if(tempLowList.includes(thisBx.value)) {thisBx.checked = true}})
    };
    if(localStorage['lowList'] != undefined || localStorage['highList'] != undefined) {highlight()}
    var rdgSum = 0;
    document.querySelectorAll('.nombre').forEach(function (thisNum) {if(thisNum.parentElement.style.display!="none") {rdgSum += parseInt(thisNum.innerHTML)}});
    document.querySelector("#rdgCount").innerHTML = rdgSum;
    document.querySelectorAll('.siglesBut').forEach((thisBut) => {
        thisBut.addEventListener('click', checkComb)
    })
    
    }
function toCollation () {window.location.href = '/main'}
function highlight () {
    highList = [];
    highFields = [];
    lowList = [];
    document.querySelectorAll('.highBx').forEach(function (thisBox) {if(thisBox.checked) {highList.push(thisBox.value)}});
    document.querySelectorAll('.lowBx').forEach(function (thisBox) {if(thisBox.checked) {lowList.push(thisBox.value)}});
    localStorage.setItem('lowList', JSON.stringify(lowList));
    localStorage.setItem('highList', JSON.stringify(highList));
    if(highList.length>0 || lowList.length>0) {document.querySelectorAll('.siglesBut').forEach(function (sgBut) {
        var splitValue = sgBut.value.split(' ');
        evaluation = true;
        highList.forEach(function (sgl) {if(!splitValue.includes(sgl)) {evaluation = false;}});
        lowList.forEach(function (sgl) {if(splitValue.includes(sgl)) {evaluation = false;}});
        if(evaluation) {//sgBut.parentElement.style.backgroundColor ="#8e70bd"; 
        sgBut.parentElement.parentElement.style.display = ""; highFields.push(sgBut)} else {//sgBut.parentElement.style.backgroundColor = "#d28e5d"; 
        sgBut.parentElement.parentElement.style.display = "none"};



    
    })
    console.log(highFields.length);
    document.querySelector('#combCount').innerHTML = highFields.length;
        if (highFields.length === 1) { highFields[0].scrollIntoView({ behavior: 'smooth', block: 'center', inline: 'center' }) };
    } else { document.querySelectorAll('.siglesBut').forEach(function (sgBut) {//sgBut.parentElement.style.backgroundColor = "#d28e5d";
    sgBut.parentElement.parentElement.style.display = "" }); document.querySelector('#combCount').innerHTML = document.querySelectorAll('.sigles').length }
    var rdgSum = 0;
    document.querySelectorAll('.nombre').forEach(function (thisNum) {if(thisNum.parentElement.style.display!="none") {rdgSum += parseInt(thisNum.innerHTML)}});
    document.querySelector("#rdgCount").innerHTML = rdgSum;
}
function seenCombs () {
    seenCb = seenSigles.split('//');
    console.log(seenCb.length);
    document.querySelectorAll('.siglesBut').forEach(function (sgBut) {btValue = sgBut.value; if(seenCb.includes(btValue)) {sgBut.parentElement.style.backgroundColor ="#8e70bd"}})

}

function checkComb (evt) {
    let siglaStr = evt.target.value;
    let sigla = siglaStr.split(' ');
    let url = '/main?method=closest'
    sigla.forEach((thisSigle) => {
        url += '&mscr%5B%5D=%23'+thisSigle;
    })
    window.location.href = url

}