({
    afterRender: function(component, helper){
        this.superAfterRender();
        var typeId = location.search.split("?")[1].split("=")[0];
        var idVal = location.search.split("?")[1].split("=")[1];       
    },
})