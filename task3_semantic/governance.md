# Keeping Our Metrics Consistent: Team Guidelines

When multiple teams build separate dashboards, it's easy for basic metrics to drift and cause confusion during business reviews. This document explains our team's approach to updating, adding, or retiring metrics within our project repository.

---

## 1. Adding a New Metric to the Project

If you need a metric that isn't currently supported by our dashboards, please follow these steps:

1. **Check What's Available:** Share your requirements and formulas with the data team first. Often, a "new metric" request can actually be answered by simply applying a different filter or dimension slice to an existing metric.
2. **Review the Data Models:** If the calculation requires fresh fields, an engineer will check whether the underlying tables have the right columns or if we need to modify our base models.
3. **Team Peer Review:** Submit your metric as a standard code update. Every modification requires a code review and sign-off from both Data Engineering (to confirm query efficiency and table alignment) and the business team lead who requested it.
4. **Write Clean Descriptions:** Every new metric must have a clear description written in plain language explaining what it measures, what it excludes, and who owns it.

---

## 2. Changing or Removing Existing Metrics

Modifying a live metric can break active reports across different business units. To handle changes safely:

1. **Map Out Dependencies:** Before updating an active formula, we run an impact check to see exactly which business dashboards or reporting tables rely on that column.
2. **Give Teams Head-Up Notices:** Any breaking change or major definition shift requires a clear heads-up notice shared on our internal engineering announcement channels.
3. **Use Versioning to Avoid Breakage:** For significant metric redesigns, we deploy the new version alongside the legacy metric. This gives our business analysts a transition window to update their charts before the old field is retired.

---

## 3. Keeping Our Repository Clean

1. **Centralized Access:** To prevent inconsistencies, downstream analytics dashboards query our data platform through our central metrics layer rather than calculating fields ad hoc against raw tables.
2. **Automated Pull Request Checks:** Our code pipeline runs automated tests on every code submission. It will automatically flag and block any updates that try to recreate an existing metric calculation under a different name.
3. **Regular Cleanups:** The data team reviews query history to find metrics with zero usage. Unused metrics are regularly flagged, communicated to team leads, and removed to keep our codebase lightweight and maintainable.