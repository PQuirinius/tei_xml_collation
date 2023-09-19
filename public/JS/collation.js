


var lessonNum
var currentButton

window.onload = init
window.onresize = function () {document.querySelectorAll(".colHead").forEach(function (thisColHead) {sigle = thisColHead.id.substring(4); firtsTd = document.querySelector(".reading"+sigle); colWidth = firtsTd.clientWidth; thisColHead.style.width = colWidth-10+"px";
corner = document.querySelectorAll(".button")[0]; corWidth = document.querySelectorAll(".button")[1].clientWidth-20; corner.style.width = corWidth+"px";
})
};

function init () {
    document.querySelector("#tableBut").addEventListener('click', toTables);
    document.querySelectorAll(".readingButton").forEach(function (thisButton) {thisButton.addEventListener("click", activateLesson);});
    document.querySelector("#backButton").addEventListener("click", returnBack);
    document.querySelectorAll(".colHead").forEach(function (thisColHead) {sigle = thisColHead.id.substring(4);
         firtsTd = document.querySelector(".reading"+sigle); colWidth = firtsTd.clientWidth; thisColHead.style.width = colWidth-10+"px";
headWidth = thisColHead.clientWidth; document.querySelectorAll(".reading"+sigle).forEach(function (thisField) {thisField.style.width = headWidth-10+"px"})})
    corner = document.querySelectorAll(".button")[0]; corWidth = document.querySelectorAll(".button")[1].clientWidth-20; corner.style.width = corWidth+"px";
}

function activateLesson (evt) {
    currentButton = evt.target;
    console.log(currentButton.innerHTML);
    lessonNum = currentButton.id.substring(6);
    document.querySelectorAll(".lessonSpan").forEach(function (thisSpan) {
    thisSpan.style.backgroundColor = "#FFFFFF";
if (thisSpan.innerHTML==="/empty/") {thisSpan.innerHTML=""}
});
    document.querySelectorAll(".apparatEntry"+lessonNum).forEach(function (thisSpan) {
    if(thisSpan.classList.contains("main")) {thisSpan.style.backgroundColor = "#d78383"} else {thisSpan.style.backgroundColor = "#f8e8c2"};
if (thisSpan.innerHTML==="") {thisSpan.innerHTML="/empty/"};
thisSpan.scrollIntoView(); thisSpan.parentNode.scrollBy(0, -75);});
window.scrollTo({left:0})
}

function returnBack () {

document.querySelector("#row"+lessonNum).scrollIntoView();
document.querySelector("thead").scrollIntoView();
window.scrollTo({left:0})
}

function toTables () {window.location.href = '/tables'}