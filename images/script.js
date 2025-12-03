let tl=gsap.timeline();
tl.to(" #fanta",{
    y:520,
    x:-325,
scrollTrigger:{
    trigger:".two",
    scroller:"body",
    start:"top 80%",
    end:"top 10%",
    scrub:1

}
})



tl.to("#leaf2",{
    y:350,
    x:90,
    scrollTrigger:{
        trigger:".two",
        scroller:"body",
        start:"top 80%",
        end:"top 10%",
        scrub:1
    }
})
tl.to("#orange",{
    y:650,
    x:410,
    scrollTrigger:{
        trigger:".two",
        scroller:"body",
        start:"top 80%",
        end:"top 10%",
        scrub:1
    }
})



tl.from(".lemon1",{
    x:-500,
    y:100,
    duration:0.5,
    scrollTrigger:{
        trigger:".three",
        scroller:"body",
        start:"top 20%",
        end:"top 10%",
        scrub:2
    }
})

tl.from(".cola",{
    x:-500,
    y:-100,
    rotate:-90,
    duration:0.5,
    scrollTrigger:{
        trigger:".three",
        scroller:"body",
        start:"top 20%",
        end:"top 10%",
        scrub:2
    }
})


tl.from(".lemon2",{
    x:500,
    y:100,
    duration:0.3,
    scrollTrigger:{
        trigger:".three",
        scroller:"body",
        start:"top 20%",
        end:"top 10%",
        scrub:2
    }
})

tl.from(".pepsi",{
    x:500,
    y:-100,
    rotate:90,
    duration:0.3,
    scrollTrigger:{
        trigger:".three",
        scroller:"body",
        start:"top 20%",
        end:"top 10%",
        scrub:2
    }
})
tl.to("#fanta",{
    top:"120%",
    left:"66%",
    width:"15%",
    rotate:0,
    scrollTrigger:{
        trigger:".three",
        scroller:"body",
        start:"top 20%",
        end:"top 10%",
        scrub:2
    }

})

  tl.to("#leaf",{
    top:"80%",scrollTrigger:{
        trigger:".two",
        scroller:"body",
        start:"top 60%",
        end:"top 10%",
        scrub:1,
    }
    
  })  
    
    


tl.to("svg",{
    opacity:1,
    duration:0.5,
    scrollTrigger:{
        trigger:".two",
        scroller:"body",
        start:"top 60%",
        end:"top 50%",
        scrub:1
    }

})
