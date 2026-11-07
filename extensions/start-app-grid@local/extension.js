import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as Overview from 'resource:///org/gnome/shell/ui/overview.js';
import GLib from 'gi://GLib';
export default class StartInAppGrid extends Extension {
  enable() {
    this._origToggle = Overview.Overview.prototype.toggle;
    Overview.Overview.prototype.toggle = function () {
      if (this.isDummy) return;
      if (this._visible) this.hide();
      else GLib.idle_add(GLib.PRIORITY_DEFAULT, () => { Main.overview.showApps(); return GLib.SOURCE_REMOVE; });
    };
  }
  disable() { if (this._origToggle) { Overview.Overview.prototype.toggle = this._origToggle; this._origToggle = null; } }
}
