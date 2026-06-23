package com.aptispace.web;

import java.util.Collection;
import java.util.LinkedHashSet;
import org.openxava.application.meta.MetaApplication;
import com.openxava.naviox.Modules;
import com.openxava.naviox.impl.IAllModulesNamesProvider;

public class AptiSpaceModulesNamesProvider implements IAllModulesNamesProvider {
    @Override
    public Collection<String> getAllModulesNames(MetaApplication app) {
        Collection<String> modules = new LinkedHashSet<>(app.getModulesNames());
        modules.remove(Modules.FIRST_STEPS);
        return modules;
    }
}
