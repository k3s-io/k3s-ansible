# `k3s-ansible` changelog (`k3s.orchestration`)

## 1.1.0

### PRs Merged

- Distribute multiple image archives (#428) 
- Don't update_cache if airgapped (#430) 
- Add missing RHEL 10 kernel module (#431) 
- Bump version in galaxy.yml (#432) 
- Inject installation envs for install script (#433) 
- docs: describe adding collection to requirements.yaml (#438) 
- Correct indentation for k3s_upgrade command (#439) 
- Fix ipv4 lookup for firewalld (#440) 
- Automatically inject tls-san when api_endpoint differs from hostname (#434)
- Remove agent jinja template (#442)
- Consolidate server templates into a single one (#443) 

For a full list of commits see [diff between 1.0.1 and 1.1.0](https://github.com/k3s-io/k3s-ansible/compare/1.0.1...1.1.0).

Thanks to all community contributors including: Claiyc, dbanetto, felix-seifert, guiand888, tambel, vd-rd!

## 1.0.0
Initial Release
