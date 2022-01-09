import Trix from 'trix'

// Set the default heading button to be h3, as we dont ever
// want someone to create h1s in Trix inside Spaces (at least for now):
// Might have to rethink this and add h2, h3 as separate buttons
// if we ever use Trix for a full page.
Trix.config.blockAttributes.heading1.tagName = 'h3';

// Add p tags:
Trix.config.blockAttributes.default.tagName = "p"
Trix.config.blockAttributes.default.breakOnReturn = true;

// P tag logic:
// Found at https://github.com/basecamp/trix/issues/680#issuecomment-735742942
Trix.Block.prototype.breaksOnReturn = function(){
    const attr = this.getLastAttribute();
    const config = Trix.getBlockConfig(attr ? attr : "default");
    return config ? config.breakOnReturn : false;
};
Trix.LineBreakInsertion.prototype.shouldInsertBlockBreak = function(){
    if(this.block.hasAttributes() && this.block.isListItem() && !this.block.isEmpty()) {
        return this.startLocation.offset > 0
    } else {
        return !this.shouldBreakFormattedBlock() ? this.breaksOnReturn : false;
    }
};
